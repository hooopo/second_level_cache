# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Core
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method_chain :find, :cache
        end

      end

      module ClassMethods
        def find_with_cache(*ids)
          return all.find(ids.first) if ids.size == 1 && ids.first.is_a?(Integer)
          find_without_cache(*ids)
        end
      end
    end
  end
end
