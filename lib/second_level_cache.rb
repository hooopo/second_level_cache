require 'active_support/all'
require 'second_level_cache/config'
require 'second_level_cache/marshal'

module SecondLevelCache
  def self.configure
    block_given? ? yield(Config) : Config
  end

  class << self
    delegate :logger, :cache_store, :cache_key_prefix, :to => Config
  end

  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :second_level_cache_options

      def acts_as_cached(options = {})
        @second_level_cache_enabled = true
        @second_level_cache_options = options
        @second_level_cache_options[:expires_in] ||= 1.day
      end

      def second_level_cache_enabled?
        !!@second_level_cache_enabled
      end

      def cache_store
        Config.cache_store
      end

      def logger
        Config.logger
      end

      def cache_key_prefix
        Config.cache_key_prefix
      end

      def second_level_cache_key(id)
        "#{cache_key_prefix}/#{name.downcase}/#{id}"
      end

      def read_second_level_cache(id)
        SecondLevelCache.cache_store.read(second_level_cache_key(id)) if self.second_level_cache_enabled?
      end

      def expire_second_level_cache(id)
        SecondLevelCache.cache_store.delete(second_level_cache_key(id)) if self.second_level_cache_enabled?
      end
    end

    def second_level_cache_key
      self.class.second_level_cache_key(id)
    end

    def expire_second_level_cache
      SecondLevelCache.cache_store.delete(second_level_cache_key) if self.class.second_level_cache_enabled?
    end

    def write_second_level_cache
      SecondLevelCache.cache_store.write(second_level_cache_key, self, self.class.second_level_cache_options) if self.class.second_level_cache_enabled?
    end
  end
end

require 'second_level_cache/active_record' if defined?(ActiveRecord)
