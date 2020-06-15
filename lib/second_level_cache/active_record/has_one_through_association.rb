# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module HasOneThroughAssociation
        private
          def find_target
            return super unless second_level_cache_enabled?

            through = reflection.options[:through]
            through_record = owner.send(through)
            return nil unless through_record

            record = klass.find_by({ klass.primary_key => through_record.read_attribute(reflection.foreign_key) })
            return nil unless record

            record.tap { |r| set_inverse_instance(r) }
          end

          def skip_statement_cache?(scope)
            second_level_cache_enabled? || super
          end

          def second_level_cache_enabled?
            klass.second_level_cache_enabled? && reflection.source_reflection.active_record.second_level_cache_enabled?
          end
      end
    end
  end
end
