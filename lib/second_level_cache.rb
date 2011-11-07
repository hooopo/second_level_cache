# encoding: utf-8

require 'arel'
require 'active_record'
require 'active_record/persistence'
require 'redis'

require File.expand_path('../marshal_fix', __FILE__) unless ENV['RAILS_ENV'] == 'production'
require File.expand_path("../arel/wheres", __FILE__)
require File.expand_path("../active_record/base", __FILE__)
require File.expand_path("../active_record/finder_methods", __FILE__)
require File.expand_path("../active_record/persistence", __FILE__)
require File.expand_path("../redis_wraper", __FILE__)

module SecondLevelCache

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
      @cache_store ||= SecondLevelCache::Redis.new($redis, :logger => logger, :default_ttl => ttl)
    end

    def cache_store=(store)
      if store.is_a?(::Redis)
        @cache_store =  SecondLevelCache::Redis.new(store, logger, ttl)
      else
        @cache_store = store
      end
    end

    def logger
      @second_level_cache_logger
    end

    def ttl
      @second_level_cache_ttl
    end
  end
end

ActiveRecord::FinderMethods.send(:include, SecondLevelCache::ActiveRecord::FinderMethods)
ActiveRecord::Persistence.send(:include, SecondLevelCache::ActiveRecord::Persistence)
ActiveRecord::Base.send(:include, SecondLevelCache::ActiveRecord::Base)
ActiveRecord::Base.send(:include, SecondLevelCache::Mixin)
