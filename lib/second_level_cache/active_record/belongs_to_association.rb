# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module BelongsToAssociation
        def find_target
          return super unless klass.second_level_cache_enabled?
          cache_record = klass.read_second_level_cache(second_level_cache_key)
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

        private
          def second_level_cache_key
            owner[reflection.foreign_key]
          end
      end
    end
  end
end
