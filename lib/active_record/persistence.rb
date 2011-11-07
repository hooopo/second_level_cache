# encoding: utf-8
module SecondLevelCache
  module ActiveRecord
    module Persistence

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method_chain :reload, :second_level_cache
        end
      end

      module InstanceMethods
        def reload_with_second_level_cache(options = nil)
          expire_second_level_cache
          reload_without_second_level_cache(options)
        end
      end
    end
  end
end
