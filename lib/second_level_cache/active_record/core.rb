# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Core
      def self.prepended(base)
        class << base
          prepend ClassMethods
        end
      end

      module ClassMethods
        def find(*ids)
          return all.find(ids.first) if ids.size == 1 && ids.first.is_a?(Fixnum)
          super(*ids)
        end
      end
    end
  end
end
