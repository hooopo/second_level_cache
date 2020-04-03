# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module Preloader
        RAILS6 = ::ActiveRecord.version >= ::Gem::Version.new("6")

        def records_for(ids, &block)
          return super unless klass.second_level_cache_enabled?
          return super unless reflection.is_a?(::ActiveRecord::Reflection::BelongsToReflection)

          map_cache_keys = ids.map { |id| klass.second_level_cache_key(id) }
          records_from_cache = ::SecondLevelCache.cache_store.read_multi(*map_cache_keys)

          record_marshals = if RAILS6
                              RecordMarshal.load_multi(records_from_cache.values) do |record|
                                # This block is copy from:
                                # https://github.com/rails/rails/blob/6-0-stable/activerecord/lib/active_record/associations/preloader/association.rb#L101
                                owner = owners_by_key[convert_key(record[association_key_name])].first
                                association = owner.association(reflection.name)
                                association.set_inverse_instance(record)
                              end
                            else
                              RecordMarshal.load_multi(records_from_cache.values, &block)
                            end

          # NOTICE
          # Rails.cache.read_multi return hash that has keys only hitted.
          # eg. Rails.cache.read_multi(1,2,3) => {2 => hit_value, 3 => hit_value}
          hitted_ids = record_marshals.map { |record| record.read_attribute(association_key_name).to_s }
          missed_ids = ids.map(&:to_s) - hitted_ids
          ::SecondLevelCache.logger.info("missed #{association_key_name} -> #{missed_ids.join(',')} | hitted #{association_key_name} -> #{hitted_ids.join(',')}")
          return SecondLevelCache::RecordRelation.new(record_marshals) if missed_ids.empty?

          records_from_db = super(missed_ids, &block)
          records_from_db.map { |r| write_cache(r) }

          SecondLevelCache::RecordRelation.new(records_from_db + record_marshals)
        end

        private

        def write_cache(record)
          record.write_second_level_cache
        end
      end
    end
  end
end
