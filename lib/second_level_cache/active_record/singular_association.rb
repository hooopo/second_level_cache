# encoding: utf-8
module SecondLevelCache
  module ActiveRecord
    module Associations
      module SingularAssociation
        def self.included(base)
          base.send(:include, InstanceMethods)
          base.class_eval do
            alias_method_chain :find_target, :second_level_cache
          end
        end

        module InstanceMethods
          def find_target_with_second_level_cache
            return find_target_without_second_level_cache unless association_class.second_level_cache_enabled?
            cache_record = association_class.cache_store.get(second_level_cache_key)
            return cache_record.tap{|record| set_inverse_instance(record)} if cache_record
            return find_target_without_second_level_cache
          end

          private

          def second_level_cache_key
            "#{aliased_table_name}/#{owner[reflection.foreign_key]}"
          end
        end
      end
    end
  end
end
