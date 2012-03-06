module SecondLevelCache
  module Config
    extend self

    attr_accessor :cache_store, :logger
  end
end
