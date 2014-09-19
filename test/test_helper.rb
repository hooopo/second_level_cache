# -*- encoding : utf-8 -*-
require 'rubygems'
require 'bundler/setup'
require 'second_level_cache'
require 'minitest/autorun'
require 'active_support/test_case'
require 'database_cleaner'

DatabaseCleaner[:active_record].strategy = :transaction

SecondLevelCache.configure do |config|
  config.cache_store = ActiveSupport::Cache::MemoryStore.new
end

SecondLevelCache.logger.level = Logger::INFO

class ActiveSupport::TestCase
  setup do
    SecondLevelCache.cache_store.clear
  end
end
