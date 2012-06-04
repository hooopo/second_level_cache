module SecondLevelCache
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      included do
        after_destroy :expire_second_level_cache
        after_save :write_second_level_cache
      end
    end
  end
end
