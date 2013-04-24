# -*- encoding : utf-8 -*-
require 'active_record/test_helper'

class ActiveRecord::FetchByUinqKeyTest < Test::Unit::TestCase
  def setup
    DatabaseCleaner[:active_record].start
    @user = User.create :name => 'hooopo', :email => 'hoooopo@gmail.com'
  end

  def test_should_query_from_db_using_primary_key
    User.fetch_by_uniq_key(@user.name, :name)
    $sql_logger = nil
    User.fetch_by_uniq_key(@user.name, :name)
    assert_equal $sql_logger.strip, 'SELECT  "users".* FROM "users"  WHERE "users"."id" = ? LIMIT 1'
  end

  def test_should_not_hit_db_using_fetch_by_uniq_key_twice
    user = User.fetch_by_uniq_key(@user.name, :name)
    assert_equal user, @user
    no_connection do
      User.fetch_by_uniq_key(@user.name, :name)
    end
  end

  def test_should_fail_when_fetch_by_uniq_key_with_bang_method
    assert_raise(ActiveRecord::RecordNotFound) do
      User.fetch_by_uniq_key!(@user.name + "not_exist", :name)
    end
  end
end
