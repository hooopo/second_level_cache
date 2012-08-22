# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      included do
        after_commit :on => :destroy do
          expire_second_level_cache
        end

        after_commit :on => :create do
          write_second_level_cache
        end

        after_commit :on => :update do
          write_second_level_cache
        end

        class << self
          alias_method_chain :update_counters, :cache
        end
      end


      module ClassMethods
        def update_counters_with_cache(id, counters)
          Array(id).each{|i| expire_second_level_cache(i)}
          update_counters_without_cache(id, counters)
        end
      end
    end
  end
end
