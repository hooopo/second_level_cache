module SecondLevelCache
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      included do |base|
        base.after_destroy :expire_second_level_cache
        base.after_save :write_second_level_cache
      end
    end
  end
end
