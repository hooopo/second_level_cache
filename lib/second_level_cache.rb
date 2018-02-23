# frozen_string_literal: true

require "active_support/all"
require "second_level_cache/config"
require "second_level_cache/record_marshal"
require "second_level_cache/record_relation"
require "second_level_cache/active_record"

module SecondLevelCache
  def self.configure
    block_given? ? yield(Config) : Config
  end

  class << self
    delegate :logger, :cache_store, :cache_key_prefix, to: Config
  end
end
