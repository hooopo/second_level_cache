# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Associations
      module BelongsToAssociation
        extend ActiveSupport::Concern
        included do
          class_eval do
            alias_method_chain :find_target, :second_level_cache
          end
        end

        def find_target_with_second_level_cache
          return find_target_without_second_level_cache unless klass.second_level_cache_enabled?
          cache_record = klass.read_second_level_cache(second_level_cache_key)
          return cache_record.tap{|record| set_inverse_instance(record)} if cache_record
          record = find_target_without_second_level_cache

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
