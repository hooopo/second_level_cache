module SecondLevelCache
  module Config
    extend self

    attr_accessor :cache_store, :logger

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
