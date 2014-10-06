# -*- encoding : utf-8 -*-
require 'bundler/setup'
require 'minitest/autorun'
require 'active_support/test_case'
require 'active_record_test_case_helper'
require 'database_cleaner'
require 'active_record'

ActiveRecord::Base.raise_in_transactional_callbacks = true if ActiveRecord::Base.respond_to?(:raise_in_transactional_callbacks=)
ActiveSupport.test_order = :sorted if ActiveSupport.respond_to?(:test_order=)

require 'second_level_cache'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

require 'model/user'
require 'model/book'
require 'model/image'
require 'model/topic'
require 'model/post'
require 'model/account'
require 'model/animal'

DatabaseCleaner[:active_record].strategy = :truncation

SecondLevelCache.configure do |config|
  config.cache_store = ActiveSupport::Cache::MemoryStore.new
end

SecondLevelCache.logger.level = Logger::ERROR
ActiveSupport::Cache::MemoryStore.logger = SecondLevelCache::Config.logger
ActiveRecord::Base.logger = SecondLevelCache::Config.logger

class ActiveSupport::TestCase
  setup do
    SecondLevelCache.cache_store.clear
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end
end
