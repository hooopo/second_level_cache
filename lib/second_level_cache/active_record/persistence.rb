module SecondLevelCache
  module ActiveRecord
    module Persistence
      extend ActiveSupport::Concern

      included do
        class_eval do
          alias_method_chain :reload, :second_level_cache
        end
      end

      def reload_with_second_level_cache(options = nil)
        expire_second_level_cache
        reload_without_second_level_cache(options)
      end
    end
  end
end
