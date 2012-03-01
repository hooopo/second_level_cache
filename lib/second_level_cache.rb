# encoding: utf-8

require 'active_record'

require 'second_level_cache/config'
require 'second_level_cache/marshal'

module SecondLevelCache
  def self.configure
    block_given? ? yield(Config) : Config
  end

  module Mixin
    def self.included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def acts_as_cached(options = {})
      @second_level_cache_status = true
      @second_level_cache_logger = options[:logger] || ::ActiveRecord::Base.logger
      @second_level_cache_ttl = options[:ttl] || 2.day
      second_level_cache_init
    end

    def second_level_cache_enabled?
      defined?(@second_level_cache_status) && @second_level_cache_status
    end

    def cache_store
      Config.cache_store
    end

    def logger
      @second_level_cache_logger
    end

    def ttl
      @second_level_cache_ttl
    end
  end
end

require 'second_level_cache/active_record' if defined?(ActiveRecord)
require 'second_level_cache/arel' if defined?(Arel)
