# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Persistence
      def update_column(name, value)
        super(name, value).tap { update_second_level_cache }
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
