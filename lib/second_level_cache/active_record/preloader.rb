# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Associations
      class Preloader
        module BelongsTo
          extend ActiveSupport::Concern

          def records(ids)
            return super(ids) unless klass.second_level_cache_enabled?

            map_cache_keys = ids.map{|id| klass.second_level_cache_key(id)}
            records_from_cache = ::SecondLevelCache.cache_store.read_multi(*map_cache_keys)
            # NOTICE
            # Rails.cache.read_multi return hash that has keys only hitted.
            # eg. Rails.cache.read_multi(1,2,3) => {2 => hit_value, 3 => hit_value}
            hitted_ids = records_from_cache.map{|key, _| key.split("/")[2].to_i}
            missed_ids = ids.map{|x| x.to_i} - hitted_ids

            ::SecondLevelCache::Config.logger.info "missed ids -> #{missed_ids.inspect} | hitted ids -> #{hitted_ids.inspect}"

            if missed_ids.empty?
              RecordMarshal.load_multi(records_from_cache.values)
            else
              records_from_db = super(missed_ids)
              records_from_db.map{|record| write_cache(record); record} + RecordMarshal.load_multi(records_from_cache.values)
            end
          end

          private

          def write_cache(record)
            record.write_second_level_cache
          end
        end
      end
    end
  end
end
