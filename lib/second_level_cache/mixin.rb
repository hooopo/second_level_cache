# frozen_string_literal: true

module SecondLevelCache
  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :second_level_cache_options

      delegate :logger, :cache_store, :cache_key_prefix, to: SecondLevelCache

      def second_level_cache(options = {})
        @second_level_cache_enabled = true
        @second_level_cache_options = options
        @second_level_cache_options[:version] ||= 0
        @second_level_cache_options[:expires_in] ||= 1.week
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

      # Get MD5 digest of this Model schema
      # http://api.rubyonrails.org/classes/ActiveRecord/Core/ClassMethods.html#method-i-inspect
      def cache_version
        return @cache_version if defined? @cache_version
        # This line is copy from:
        # https://github.com/rails/rails/blob/f9a5f48/activerecord/lib/active_record/core.rb#L236
        attr_list = attribute_types.map { |name, type| "#{name}: #{type.type}" } * ", "
        model_schema_digest = Digest::MD5.hexdigest(attr_list)
        @cache_version = "#{second_level_cache_options[:version]}/#{model_schema_digest}"
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
      klass.second_level_cache_key(id)
    end

    def klass
      self.class.base_class
    end

    def expire_second_level_cache
      return unless klass.second_level_cache_enabled?
      SecondLevelCache.cache_store.delete(second_level_cache_key)
    end

    def write_second_level_cache
      return unless klass.second_level_cache_enabled?
      marshal = RecordMarshal.dump(self)
      expires_in = klass.second_level_cache_options[:expires_in]
      expire_changed_association_uniq_keys
      SecondLevelCache.cache_store.write(second_level_cache_key, marshal, expires_in: expires_in)
    end

    alias update_second_level_cache write_second_level_cache

    def expire_changed_association_uniq_keys
      uniq_keys = klass.send(:read_uniq_keys)

      changed_keys = uniq_keys.reject do |keys|
        (previous_changes.keys | keys).empty?
      end

      changed_keys.each do |keys|
        where_values = {}
        keys.each do |key|
          where_values[key] = if previous_changes.key?(key)
                                previous_changes[key][0]
                              else
                                read_attribute(key)
                              end
        end
        SecondLevelCache.cache_store.delete(klass.send(:cache_uniq_key, where_values))
      end
    end
  end
end
