module SecondLevelCache
  module Adapter
    module Paranoia
      module ActiveRecord
        extend ActiveSupport::Concern

        included do
          after_destroy :expire_second_level_cache
        end
      end

      module Mixin
        extend ActiveSupport::Concern

        def write_second_level_cache
          # Avoid rewrite cache again, when record has been soft deleted
          return if respond_to?(:deleted?) && send(:deleted?)
          super
        end
        alias update_second_level_cache write_second_level_cache
      end
    end
  end
end
