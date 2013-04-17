# -*- encoding : utf-8 -*-
require 'rubygems'
require 'bundler/setup'
require 'second_level_cache'
require 'test/unit'
require 'database_cleaner'

DatabaseCleaner[:active_record].strategy = :transaction

SecondLevelCache.configure do |config|
  config.cache_store = ActiveSupport::Cache::MemoryStore.new
end

SecondLevelCache.logger.level = Logger::INFO
