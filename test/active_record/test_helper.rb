# -*- encoding : utf-8 -*-
require 'test_helper'
require 'active_record'
require 'second_level_cache/active_record'

def open_test_db_connect
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'test/test.sqlite3'
  )
end
open_test_db_connect

def close_test_db_connect
  ActiveRecord::Base.connection.disconnect!
end

class Minitest::Test
  def no_connection
    close_test_db_connect
    assert_nothing_raised { yield }
  ensure
    open_test_db_connect
  end
  
  
  def assert_nothing_raised(*)
    yield
  end

  def teardown
    $sql_logger = nil
    SecondLevelCache.cache_store.clear
    DatabaseCleaner[:active_record].clean
  end
end

module ActiveRecord
  module Querying
    def find_by_sql_with_test(sql, binds = [])
      $sql_logger ||= ""
      $sql_logger << sql.to_sql
      $sql_logger << "\n"
      find_by_sql_without_test(sql, binds)
    end
    alias_method_chain :find_by_sql, :test
  end
end

require 'active_record/model/user'
require 'active_record/model/book'
require 'active_record/model/image'
require 'active_record/model/topic'
require 'active_record/model/post'
require 'active_record/model/account'
