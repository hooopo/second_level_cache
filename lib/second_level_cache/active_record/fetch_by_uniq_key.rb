# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module FetchByUniqKey
      def fetch_by_uniq_key(value, uniq_key_name)
        return self.where(uniq_key_name => value).first unless self.second_level_cache_enabled?
        if iid = SecondLevelCache.cache_store.read(cache_uniq_key(value, uniq_key_name))
          self.find_by_id(iid)
        else
          record = self.where(uniq_key_name => value).first
          record.tap{|record| SecondLevelCache.cache_store.write(cache_uniq_key(value, uniq_key_name), record.id)} if record
        end
      end

      def fetch_by_uniq_key!(value, uniq_key_name)
        fetch_by_uniq_key(value, uniq_key_name) || raise(::ActiveRecord::RecordNotFound)
      end

      private

      def cache_uniq_key(value, uniq_key_name)
        "uniq_key_#{self.name}_#{uniq_key_name}_#{value}"
      end
    end
  end
end
