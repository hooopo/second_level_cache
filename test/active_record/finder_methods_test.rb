# -*- encoding : utf-8 -*-
require 'active_record/test_helper'

class ActiveRecord::FinderMethodsTest < Test::Unit::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
  end

  def test_should_find_without_cache
    SecondLevelCache.cache_store.clear
    assert_equal @user, User.find(@user.id)
  end

  def test_should_find_with_cache
    no_connection do
      assert_equal @user, User.find(@user.id)
    end
  end

  def test_should_find_with_condition
    no_connection do
      assert_equal @user, User.where(:name => @user.name).find(@user.id)
    end
  end
end
