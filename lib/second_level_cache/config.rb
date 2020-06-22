# frozen_string_literal: true

module SecondLevelCache
  class Config
    class << self
      attr_writer :cache_store, :cache_key_prefix

      def cache_store
        @cache_store ||= Rails.cache if defined?(Rails)
        @cache_store
      end

      def cache_key_prefix
        @cache_key_prefix ||= "slc"
      end

      # This configuration must be on the first line
      def legacy
        require "second_level_cache/adapter/legacy"
      end
    end
  end
end
