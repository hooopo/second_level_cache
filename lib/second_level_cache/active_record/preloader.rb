module SecondLevelCache
  module ActiveRecord
    module Associations
      class Preloader
        module BelongsTo
          def records_for(ids)
            return super(ids) unless klass.second_level_cache_enabled?

            map_cache_keys = ids.map { |id| klass.second_level_cache_key(id) }
            records_from_cache = ::SecondLevelCache.cache_store.read_multi(*map_cache_keys)
            # NOTICE
            # Rails.cache.read_multi return hash that has keys only hitted.
            # eg. Rails.cache.read_multi(1,2,3) => {2 => hit_value, 3 => hit_value}
            hitted_ids = records_from_cache.map do |key, _| 
              id = key.split('/')[2]
              integer? ? id.to_i : id
            end
            missed_ids = (integer? ? ids.map(&:to_i) : ids) - hitted_ids

            ::SecondLevelCache.logger.info "missed ids -> #{missed_ids.inspect} | hitted ids -> #{hitted_ids.inspect}"

            record_marshals = RecordMarshal.load_multi(records_from_cache.values)

            if missed_ids.empty?
              return SecondLevelCache::RecordRelation.new(record_marshals)
            end

            records_from_db = super(missed_ids)
            records_from_db.map do |r|
              write_cache(r)
            end

            SecondLevelCache::RecordRelation.new(records_from_db + record_marshals)
          end

          private

          def integer?
            primary_key_attribute = klass.attribute_types.select { |name, type| name == User.primary_key }
            if primary_key_attribute.key?(klass.primary_key.to_s)
              primary_key_attribute[klass.primary_key].type == :integer
            else
              true
            end
          end

          def write_cache(record)
            record.write_second_level_cache
          end
        end
      end
    end
  end
end
