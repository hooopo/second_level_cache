# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module Preloader
        def records_for(ids, &block)
          return super(ids, &block) unless klass.second_level_cache_enabled?
          if reflection.is_a?(::ActiveRecord::Reflection::BelongsToReflection)
            map_cache_keys = ids.map { |id| klass.second_level_cache_key(id) }
          elsif reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection)
            map_uniq_keys = ids.map { |id| klass.send(:cache_uniq_key, association_key_name => id) }
            ids_ = ::SecondLevelCache.cache_store.read_multi(*map_uniq_keys).values
            map_cache_keys = ids_.map { |id| klass.second_level_cache_key(id) }
          else
            return super(ids, &block)
          end
          records_from_cache = ::SecondLevelCache.cache_store.read_multi(*map_cache_keys)
          record_marshals = RecordMarshal.load_multi(records_from_cache.values)

          # NOTICE
          # Rails.cache.read_multi return hash that has keys only hitted.
          # eg. Rails.cache.read_multi(1,2,3) => {2 => hit_value, 3 => hit_value}
          hitted_ids = record_marshals.map { |record| record.read_attribute(association_key_name) }
          missed_ids = ids.map(&:to_s) - hitted_ids.map(&:to_s)
          ::SecondLevelCache.logger.info("missed #{association_key_name} -> #{missed_ids.join(',')} | hitted #{association_key_name} -> #{hitted_ids.join(',')}")
          return SecondLevelCache::RecordRelation.new(record_marshals) if missed_ids.empty?

          records_from_db = super(missed_ids, &block)
          records_from_db.map { |r| write_cache(r) }

          SecondLevelCache::RecordRelation.new(records_from_db + record_marshals)
        end

        private

        def write_cache(record)
          if reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection)
            ::SecondLevelCache.cache_store.write(
              klass.send(:cache_uniq_key, association_key_name => record.read_attribute(association_key_name)),
              record.id
            )
          end
          record.write_second_level_cache
        end
      end
    end
  end
end
