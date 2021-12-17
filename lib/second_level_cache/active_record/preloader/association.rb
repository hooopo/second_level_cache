# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module Preloader
        module Association
          # In Rails 7, override load_query for assign self
          def loader_query
            ::ActiveRecord::Associations::Preloader::Association::LoaderQuery.new(self, scope, association_key_name)
          end

          module LoaderQuery
            attr_reader :association

            delegate :klass, to: :association

            def initialize(association, scope, association_key_name)
              @association = association
              @scope = scope
              @association_key_name = association_key_name
            end

            def reflection
              association.send(:reflection)
            end

            def load_records_for_keys(keys, &block)
              ids = keys.to_a

              return super unless klass.second_level_cache_enabled?
              return super unless reflection.is_a?(::ActiveRecord::Reflection::BelongsToReflection)
              return super if klass.default_scopes.present? || reflection.scope
              return super if association_key_name.to_s != klass.primary_key

              map_cache_keys = ids.map { |id| klass.second_level_cache_key(id) }
              records_from_cache = ::SecondLevelCache.cache_store.read_multi(*map_cache_keys)
              record_marshals = RecordMarshal.load_multi(records_from_cache.values, &block)

              # NOTICE
              # Rails.cache.read_multi return hash that has keys only hitted.
              # eg. Rails.cache.read_multi(1,2,3) => {2 => hit_value, 3 => hit_value}
              hitted_ids = record_marshals.map { |record| record.read_attribute(association_key_name).to_s }
              missed_ids = ids.map(&:to_s) - hitted_ids
              ActiveSupport::Notifications.instrument("preload.second_level_cache", key: association_key_name, hit: hitted_ids, miss: missed_ids)
              return SecondLevelCache::RecordRelation.new(record_marshals) if missed_ids.empty?

              records_from_db = super(missed_ids.to_set, &block)
              records_from_db.map { |r| r.write_second_level_cache }

              SecondLevelCache::RecordRelation.new(records_from_db + record_marshals)
            end
          end
        end
      end
    end
  end
end
