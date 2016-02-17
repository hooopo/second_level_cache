module SecondLevelCache
  module ActiveRecord
    module Associations
      module HasOneAssociation
        def find_target
          return super unless klass.second_level_cache_enabled?
          return super if reflection.options[:through] || reflection.scope
          # TODO: implement cache with has_one through, scope

          owner_primary_key = owner[reflection.active_record_primary_key]
          if reflection.options[:as]
            keys = {
              reflection.foreign_key => owner_primary_key,
              reflection.type => owner.class.base_class.name
            }
            cache_record = klass.fetch_by_uniq_keys(keys)
          else
            cache_record = klass.fetch_by_uniq_key(owner_primary_key, reflection.foreign_key)
          end

          if cache_record
            return cache_record.tap { |record| set_inverse_instance(record) }
          end

          record = super
          return nil unless record

          record.tap do |r|
            set_inverse_instance(r)
            r.write_second_level_cache
          end
        end
      end
    end
  end
end
