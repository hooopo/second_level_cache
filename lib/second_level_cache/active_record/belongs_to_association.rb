module SecondLevelCache
  module ActiveRecord
    module Associations
      module BelongsToAssociation
        def find_target
          return super unless klass.second_level_cache_enabled?
          cache_record = klass.read_second_level_cache(second_level_cache_key)
          return cache_record.tap { |record| set_inverse_instance(record) } if cache_record
          record = super

          record.tap do |r|
            set_inverse_instance(r)
            r.write_second_level_cache
          end if record
        end

        private

        def second_level_cache_key
          owner[reflection.foreign_key]
        end
      end
    end
  end
end
