module SecondLevelCache
  class RecordRelation < Array
    # A fake Array for fix Rails 5.0.1 records_for method changed bug
    # in Rails 5.0.0 called:
    #   records_for()
    #
    # but 5.0.1 called:
    #   records_for().load(&block)
    #
    # https://github.com/rails/rails/pull/26340/
    def load(&block)
      return self
    end
  end
end