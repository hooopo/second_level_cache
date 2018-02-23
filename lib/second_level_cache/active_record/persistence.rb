# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Persistence
      # update_column will call update_columns
      def update_columns(attributes)
        super(attributes).tap { update_second_level_cache }
      end

      def reload(options = nil)
        expire_second_level_cache
        super(options)
      end

      def touch(*names)
        super(*names).tap { update_second_level_cache }
      end
    end
  end
end
