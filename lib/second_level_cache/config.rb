# frozen_string_literal: true

module SecondLevelCache
  class Config
    class << self
      attr_writer :cache_store, :logger, :cache_key_prefix

      def cache_store
        @cache_store ||= Rails.cache if defined?(Rails)
        @cache_store
      end

      def logger
        ActiveSupport::Deprecation.warn("logger is deprecated and will be removed from SecondLevelCache 2.7.0")
        @logger ||= Rails.logger if defined?(Rails)
        @logger ||= Logger.new(STDOUT)
      end

      def cache_key_prefix
        @cache_key_prefix ||= "slc"
      end
    end
  end
end
