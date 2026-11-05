# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module BelongsToAssociation
        # Rails 8+ calls find_target(async:). async: true must return Active Record's
        # Promise; only the synchronous reader (async: false / omitted) is cached.
        # Empty keyword splats stay compatible with the parameterless method on older Rails.
        def find_target(*args, **kwargs)
          return super(*args, **kwargs) if kwargs[:async]
          return super(*args, **kwargs) unless klass.second_level_cache_enabled?
          return super(*args, **kwargs) if klass.default_scopes.present? || reflection.scope
          return super(*args, **kwargs) if reflection.active_record_primary_key.to_s != klass.primary_key

          cache_record = klass.read_second_level_cache(second_level_cache_key)
          if cache_record
            return cache_record.tap { |record| set_inverse_instance(record) }
          end

          record = super(*args, **kwargs)
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
