# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Associations
      module HasOneAssociation
        def find_target
          return super unless klass.second_level_cache_enabled?
          return super if reflection.options[:through] || reflection.scope
          # TODO: implement cache with has_one through, scope
          if reflection.options[:as]
            keys = {
              reflection.foreign_key => owner[reflection.active_record_primary_key],
              reflection.type => owner.class.base_class.name
            }
            cache_record = klass.fetch_by_uniq_keys(keys)
          else
            cache_record = klass.fetch_by_uniq_key(owner[reflection.active_record_primary_key], reflection.foreign_key)
          end
          return cache_record.tap { |record| set_inverse_instance(record) } if cache_record

          record = super

          record.tap do |r|
            set_inverse_instance(r)
            r.write_second_level_cache
          end if record
        end
      end
    end
  end
end
