# frozen_string_literal: true

require "active_support/all"
require "second_level_cache/config"
require "second_level_cache/record_marshal"
require "second_level_cache/record_relation"
require "second_level_cache/active_record"
require "second_level_cache/log_subscriber"

module SecondLevelCache
  def self.configure
    block_given? ? yield(Config) : Config
  end

  def self.without_second_level_cache
    old_cache_enabled = SecondLevelCache.cache_enabled?
    SecondLevelCache.cache_enabled = false

    yield
  ensure
    SecondLevelCache.cache_enabled = old_cache_enabled
  end

  def self.cache_enabled?
    if self.cache_store.is_a?(ActiveSupport::Cache::NullStore)
      return false
    end
    cache_enabled = Thread.current[:slc_cache_enabled]
    cache_enabled.nil? ? true : cache_enabled
  end

  def self.cache_enabled=(cache_enabled)
    Thread.current[:slc_cache_enabled] = cache_enabled
  end

  class << self
    delegate :logger, :cache_store, :cache_key_prefix, to: Config
  end
end
