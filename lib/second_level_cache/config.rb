module SecondLevelCache
  module Config
    extend self

    attr_accessor :cache_store, :logger

    def cache_store
      @cache_store ||= Rails.cache if defined?(Rails)
      @cache_store
    end

    def logger
      @logger ||= Rails.logger if defined?(Rails)
      @logger ||= Logger.new(STDOUT)
      @logger
    end
  end
end
