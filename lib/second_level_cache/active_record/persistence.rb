# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Persistence
      # update_column will call update_columns
      # https://github.com/rails/rails/blob/5-0-stable/activerecord/lib/active_record/persistence.rb#L315
      def update_columns(attributes)
        super(attributes).tap { update_second_level_cache }
      end

      # https://github.com/rails/rails/blob/5-0-stable/activerecord/lib/active_record/persistence.rb#L441
      def reload(options = nil)
        expire_second_level_cache
        super(options)
      end

      # https://github.com/rails/rails/blob/5-0-stable/activerecord/lib/active_record/persistence.rb#L490
      def touch(*names, **opts)
        # super: touch(*names, time: nil)
        super(*names, **opts).tap { update_second_level_cache }
      end
    end
  end
end
