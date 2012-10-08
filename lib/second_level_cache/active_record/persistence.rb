# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Persistence
      extend ActiveSupport::Concern

      included do
        class_eval do
          alias_method_chain :reload, :second_level_cache
          alias_method_chain :touch, :second_level_cache
          alias_method_chain :update_column, :second_level_cache
        end
      end

      def update_column_with_second_level_cache(name, value)
        update_column_without_second_level_cache(name, value).tap{update_second_level_cache}
      end

      def reload_with_second_level_cache(options = nil)
        reload_without_second_level_cache(options).tap{expire_second_level_cache}
      end

      def touch_with_second_level_cache(name = nil)
        touch_without_second_level_cache(name).tap{update_second_level_cache}
      end
    end
  end
end
