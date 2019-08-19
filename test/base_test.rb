# frozen_string_literal: true

require "test_helper"

class BaseTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: "csdn", email: "test@csdn.com"
  end

  def test_should_update_cache_when_update_attributes
    @user.update! name: "change"
    assert_equal @user.name, User.read_second_level_cache(@user.id).name
  end

  def test_should_update_cache_when_update_attribute
    @user.update_attribute :name, "change"
    assert_equal @user.name, User.read_second_level_cache(@user.id).name
  end

  def test_should_expire_cache_when_destroy
    @user = User.create name: "csdn", email: "test@csdn.com"
    @user.destroy
    assert_nil User.find_by_id(@user.id)
    assert_nil SecondLevelCache.cache_store.read(@user.second_level_cache_key)
    assert_nil User.read_second_level_cache(@user.id)
  end

  def test_should_expire_cache_when_update_counters
    assert_equal 0, @user.books_count
    @user.books.create!
    assert_nil User.read_second_level_cache(@user.id)
    user = User.find(@user.id)
    assert_equal 1, user.books_count
  end
end
