# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module FetchByUniqKey
      def fetch_by_uniq_keys(where_values)
        cache_key = cache_uniq_key(where_values)
        obj_id = SecondLevelCache.cache_store.read(cache_key)
        if obj_id
          begin
            return find(obj_id)
          rescue ::ActiveRecord::RecordNotFound
            SecondLevelCache.cache_store.delete(cache_key)
          rescue StandardError
            return nil
          end
        end

        record = where(where_values).first
        return nil unless record

        record.tap do |r|
          SecondLevelCache.cache_store.write(cache_key, r.id)
          write_uniq_keys(where_values.keys)
        end
      end

      def fetch_by_uniq_keys!(where_values)
        fetch_by_uniq_keys(where_values) || raise(::ActiveRecord::RecordNotFound)
      end

      def fetch_by_uniq_key(value, uniq_key_name)
        # puts "[Deprecated] will remove in the future,
        # use fetch_by_uniq_keys method instead."
        fetch_by_uniq_keys(uniq_key_name => value)
      end

      def fetch_by_uniq_key!(value, uniq_key_name)
        # puts "[Deprecated] will remove in the future,
        # use fetch_by_uniq_keys! method instead."
        fetch_by_uniq_key(value, uniq_key_name) || raise(::ActiveRecord::RecordNotFound)
      end

      private

      def cache_uniq_key(where_values)
        keys = where_values.collect do |k, v|
          v = Digest::MD5.hexdigest(v) if v && v.size >= 32
          [k, v].join("_")
        end

        ext_key = keys.join(",")
        "uniq_key_#{name}_#{ext_key}"
      end

      def key_of_uniq_keys
        "key_of_uniq_keys_#{name}"
      end

      def write_uniq_keys(uniq_keys)
        uniq_keys_store = read_uniq_keys
        unless uniq_keys_store.include?(uniq_keys)
          uniq_keys_store << uniq_keys
          SecondLevelCache.cache_store.write(key_of_uniq_keys, uniq_keys_store)
        end
      end

      def read_uniq_keys
        SecondLevelCache.cache_store.read(key_of_uniq_keys) || []
      end
    end
  end
end
