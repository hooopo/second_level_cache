# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      included do
        after_commit :expire_second_level_cache, :on => :destroy
        after_commit :update_second_level_cache, :on => :update
        after_commit :write_second_level_cache, :on => :create

        class << self
          alias_method_chain :update_counters, :cache
        end
      end


      module ClassMethods
        def update_counters_with_cache(id, counters)
          update_counters_without_cache(id, counters).tap do
            Array(id).each{|i| expire_second_level_cache(i)}
          end
        end
      end
    end
  end
end
