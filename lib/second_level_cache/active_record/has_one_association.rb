# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module HasOneAssociation
        def find_target
          return super unless klass.second_level_cache_enabled?
          return super if reflection.scope
          # TODO: implement cache with has_one scope

          through = reflection.options[:through]
          record  = if through
            return super unless klass.reflections[through.to_s].klass.second_level_cache_enabled?
            begin
              reflection.klass.find(owner.send(through).read_attribute(reflection.foreign_key))
            rescue StandardError
              nil
            end
          else
            uniq_keys = { reflection.foreign_key => owner[reflection.active_record_primary_key] }
            uniq_keys[reflection.type] = owner.class.base_class.name if reflection.options[:as]
            klass.fetch_by_uniq_keys(uniq_keys)
          end

          return nil unless record
          record.tap { |r| set_inverse_instance(r) }
        end
      end
    end
  end
end
