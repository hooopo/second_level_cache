# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './test_case'

require 'active_record'

require 'second_level_cache/active_record'

def open_test_db_connect
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'test/test.sqlite3'
  )
end
open_test_db_connect

require 'active_record/model/user'
require 'active_record/model/book'
require 'active_record/model/image'
require 'active_record/model/topic'
require 'active_record/model/post'
require 'active_record/model/account'
