# frozen_string_literal: true

module SecondLevelCache
  class RecordRelation < Array
    # A fake Array for fix ActiveRecord 5.0.1 records_for method changed bug
    #
    # in ActiveRecord 5.0.0 called:
    #   records_for(slice)
    #
    # but 5.0.1 called:
    #   https://github.com/rails/rails/blob/master/activerecord/lib/active_record/associations/preloader/association.rb#L118
    #   records_for(slice).load(&block)
    #
    # https://github.com/rails/rails/pull/26340
    def load(&_block)
      self
    end
  end
end
