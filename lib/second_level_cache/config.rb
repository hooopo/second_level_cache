# -*- encoding : utf-8 -*-
module SecondLevelCache
  module Config
    extend self

    attr_accessor :cache_store, :logger, :cache_key_prefix

    def cache_store
      @cache_store ||= Rails.cache if defined?(Rails)
      @cache_store
    end

    def logger
      @logger ||= Rails.logger if defined?(Rails)
      @logger ||= Logger.new(STDOUT)
    end

    def cache_key_prefix
      @cache_key_prefix ||= 'slc'
    end
  end
end
