# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module HasOneAssociation
        def find_target
          return super unless klass.second_level_cache_enabled?
          through = reflection.options[:through]
          return super unless through
          return super unless klass.reflect_on_association(through).klass.second_level_cache_enabled?
          record = klass.find_by({ klass.primary_key => owner.send(through).read_attribute(reflection.foreign_key) })
          return nil unless record
          record.tap { |r| set_inverse_instance(r) }
        end
      end
    end
  end
end
