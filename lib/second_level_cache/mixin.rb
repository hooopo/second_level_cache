# frozen_string_literal: true

module SecondLevelCache
  module Mixin
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :second_level_cache_options

      delegate :cache_store, :cache_key_prefix, to: SecondLevelCache

      def second_level_cache(options = {})
        @second_level_cache_enabled = true
        @second_level_cache_options = options
        @second_level_cache_options[:version] ||= 0
        @second_level_cache_options[:expires_in] ||= 1.week
        @second_level_cache_options[:unique_indexes] ||= []
        @second_level_cache_options[:unique_indexes].prepend(primary_key).map! do |indexes|
          Array.wrap(indexes).map(&:to_s).sort
        end
        @second_level_cache_options[:unique_indexes].uniq!
        @second_level_cache_options[:unique_indexes].sort_by!(&:size)

        include SecondLevelCache::ActiveRecord::Core
      end

      def second_level_cache_enabled?
        !!@second_level_cache_enabled
      end

      def cache_version
        @cache_version ||= "#{second_level_cache_options[:version]}/#{Digest::SHA1.hexdigest(base_class.inspect).first(7)}"
      end

      def second_level_cache_unique_where_values_hash(where_values_hash)
        where_values_hash = where_values_hash.stringify_keys
        second_level_cache_options[:unique_indexes].any? do |indexes|
          if indexes.all? { |index| where_values_hash.has_key?(index) }
            return where_values_hash.slice(*indexes)
          end
        end
        {}
      end

      def second_level_cache_key(where_values_hash)
        uniq_key = where_values_hash.map do |k, v|
          v = Digest::SHA1.hexdigest(v).first(7) if v.respond_to?(:size) && v.size > 40
          "#{k}=#{v}"
        end.sort.join("&")

        "#{cache_key_prefix}/#{table_name}/#{uniq_key}/#{cache_version}"
      end

      def read_second_level_cache(where_values_hash, &block)
        return unless second_level_cache_enabled?
        fit_hash = second_level_cache_unique_where_values_hash(where_values_hash)
        return if fit_hash.empty?

        entity = SecondLevelCache.cache_store.read(second_level_cache_key(fit_hash))
        return if entity.nil?
        entity = SecondLevelCache.cache_store.read(second_level_cache_key({ primary_key => entity })) unless entity.is_a?(Array)
        record = RecordMarshal.load(entity, &block)
        record if record && verify_second_level_cache?(record, where_values_hash)
      end

      # FIXME: The cache should be verify before AR is instantiated
      def verify_second_level_cache?(record, where_values_hash)
        where_values_hash.all? { |k, v| record.read_attribute(k) == type_for_attribute(k).cast(v) }
      end

      def expire_second_level_cache(where_values_hash)
        return unless second_level_cache_enabled?

        read_second_level_cache(where_values_hash)&.expire_second_level_cache
      end
    end

    def second_level_cache_key(*indexes)
      where_values_hash = indexes.each_with_object({}) do |index, hash|
        hash[index] = read_attribute(index)
      end
      klass.second_level_cache_key(where_values_hash)
    end

    def klass
      self.class.base_class
    end

    def expire_second_level_cache
      return unless klass.second_level_cache_enabled?

      klass.second_level_cache_options[:unique_indexes].each do |indexes|
        # TODO: implement Rails 6.1 delete_multi
        SecondLevelCache.cache_store.delete(second_level_cache_key(*indexes))
      end
    end

    def write_second_level_cache
      return unless klass.second_level_cache_enabled?

      hash = klass.second_level_cache_options[:unique_indexes].each_with_object({}) do |indexes, h|
        h[second_level_cache_key(*indexes)] = id
      end
      hash[second_level_cache_key(@primary_key)] = RecordMarshal.dump(self)
      SecondLevelCache.cache_store.write_multi(hash, expires_in: klass.second_level_cache_options[:expires_in])
    end

    def update_second_level_cache(changes_hash = previous_changes)
      return unless klass.second_level_cache_enabled?

      previous_changes_keys = changes_hash.keys
      delete_where_values_hash, update_where_values_hash = {}, {}
      hash = klass.second_level_cache_options[:unique_indexes].each_with_object({}) do |indexes, h|
        next if (indexes & previous_changes_keys).empty?
        indexes.each do |index|
          changes = changes_hash[index]
          delete_where_values_hash[index] = changes&.first || read_attribute(index)
          update_where_values_hash[index] = changes&.last || read_attribute(index)
        end
        # TODO: implement Rails 6.1 delete_multi
        SecondLevelCache.cache_store.delete(klass.second_level_cache_key(delete_where_values_hash))
        delete_where_values_hash.clear
        h[klass.second_level_cache_key(update_where_values_hash)] = id
        update_where_values_hash.clear
      end
      hash[second_level_cache_key(@primary_key)] = RecordMarshal.dump(self)
      SecondLevelCache.cache_store.write_multi(hash, expires_in: klass.second_level_cache_options[:expires_in])
    end
  end
end
