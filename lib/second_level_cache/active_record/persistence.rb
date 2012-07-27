# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Persistence
      extend ActiveSupport::Concern

      included do
        class_eval do
          alias_method_chain :reload, :second_level_cache
          alias_method_chain :touch, :second_level_cache
        end
      end

      def reload_with_second_level_cache(options = nil)
        expire_second_level_cache
        reload_without_second_level_cache(options)
      end

      def touch_with_second_level_cache(name = nil)
        if result = touch_without_second_level_cache(name)
          expire_second_level_cache
        end
        return result
      end
    end
  end
end
