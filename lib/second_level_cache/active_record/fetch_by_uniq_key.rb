# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module FetchByUniqKey
      def fetch_by_uniq_keys(where_values)
        cache_key = cache_uniq_key(where_values)
        obj_id = SecondLevelCache.cache_store.read(cache_key)

        if obj_id
          record = begin
                     find(obj_id)
                   rescue StandardError
                     nil
                   end
        end
        return record if compare_record_attributes_with_where_values(record, where_values)
        record = where(where_values).first
        if record
          SecondLevelCache.cache_store.write(cache_key, record.id)
          return record
        else
          SecondLevelCache.cache_store.delete(cache_key)
          return nil
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
          v = Digest::MD5.hexdigest(v) if v.respond_to?(:size) && v.size >= 32
          [k, v].join("_")
        end

        ext_key = keys.join(",")
        "uniq_key_#{name}_#{ext_key}"
      end

      def compare_record_attributes_with_where_values(record, where_values)
        return false unless record
        where_values.all? do |k, v|
          attribute_value = record.read_attribute(k)
          attribute_value == case attribute_value
                             when String
                               v.to_s
                             when Numeric
                               v.to_f
                             when Date
                               v.to_date
                             else # Maybe NilClass/?
                               v
                             end
        end
      end
    end
  end
end
