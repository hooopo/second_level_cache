require 'active_support/all'
require 'second_level_cache/config'
require 'second_level_cache/record_marshal'
require 'second_level_cache/record_relation'

module SecondLevelCache
  def self.configure
    block_given? ? yield(Config) : Config
  end

  class << self
    delegate :logger, :cache_store, :cache_key_prefix, to: Config
  end

  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :second_level_cache_options

      delegate :logger, :cache_store, :cache_key_prefix, to: SecondLevelCache

      def second_level_cache(options = {})
        @second_level_cache_enabled = true
        @second_level_cache_options = options
        @second_level_cache_options[:expires_in] ||= 1.week
        @second_level_cache_options[:version] ||= 0
        relation.class.send :prepend, SecondLevelCache::ActiveRecord::FinderMethods
        prepend SecondLevelCache::ActiveRecord::Core
      end

      def second_level_cache_enabled?
        if defined? @second_level_cache_enabled
          @second_level_cache_enabled == true
        else
          false
        end
      end

      def without_second_level_cache
        old = @second_level_cache_enabled
        @second_level_cache_enabled = false

        yield if block_given?
      ensure
        @second_level_cache_enabled = old
      end

      def cache_version
        second_level_cache_options[:version]
      end

      def second_level_cache_key(id)
        "#{cache_key_prefix}/#{table_name.downcase}/#{id}/#{cache_version}"
      end

      def read_second_level_cache(id)
        return unless second_level_cache_enabled?
        RecordMarshal.load(SecondLevelCache.cache_store.read(second_level_cache_key(id)))
      end

      def expire_second_level_cache(id)
        return unless second_level_cache_enabled?
        SecondLevelCache.cache_store.delete(second_level_cache_key(id))
      end
    end

    def second_level_cache_key
      self.class.second_level_cache_key(id)
    end

    def expire_second_level_cache
      return unless self.class.second_level_cache_enabled?
      SecondLevelCache.cache_store.delete(second_level_cache_key)
    end

    def write_second_level_cache
      return unless self.class.second_level_cache_enabled?
      marshal = RecordMarshal.dump(self)
      expires_in = self.class.second_level_cache_options[:expires_in]
      expire_changed_association_uniq_keys
      SecondLevelCache.cache_store.write(second_level_cache_key, marshal, expires_in: expires_in)
    end

    alias update_second_level_cache write_second_level_cache

    def expire_changed_association_uniq_keys
      reflections = self.class.reflections.select { |_, reflection| reflection.belongs_to? }
      changed_keys = reflections.map { |_, reflection| reflection.foreign_key } & previous_changes.keys
      changed_keys.each do |key|
        SecondLevelCache.cache_store.delete(self.class.send(:cache_uniq_key, key => previous_changes[key][0]))
      end
    end
  end
end

require 'second_level_cache/active_record' if defined?(ActiveRecord)
