module SecondLevelCache
  module ActiveRecord
    module MultiReadFromCache
      def multi_read_from_cache(ids)
        map_cache_keys = ids.map{|id| second_level_cache_key(id)}
        records_from_cache = ::SecondLevelCache.cache_store.read_multi(*map_cache_keys)
        hitted_ids = records_from_cache.map{|key, _| key.split("/")[2].to_i}
        missed_ids = ids.map{|x| x.to_i} - hitted_ids

        ::SecondLevelCache::Config.logger.info "missed ids -> #{missed_ids.inspect} | hitted ids -> #{hitted_ids.inspect}"

        if missed_ids.empty?
          RecordMarshal.load_multi(records_from_cache.values)
        else
          records_from_db = where(:id => missed_ids)
          records_from_db.map{|record| record.write_second_level_cache ; record} + RecordMarshal.load_multi(records_from_cache.values)
        end
      end
    end
  end
end