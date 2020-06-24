# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Persistence
      # update_column will call update_columns
      # previous_changes is incorrect in here, so we must be corrected it
      def update_columns(attributes)
        changes_hash = {}
        attributes.each do |k, v|
          changes_hash[k.to_s] = [read_attribute(k), v]
        end
        super.tap { update_second_level_cache(changes_hash) }
      end

      def reload(options = nil)
        expire_second_level_cache
        super
      end
    end
  end
end
