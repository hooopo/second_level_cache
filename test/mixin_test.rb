# frozen_string_literal: true

require "test_helper"

class MixinTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: "csdn", email: "test@csdn.com"
  end

  def test_should_return_default_value
    assert_equal User.second_level_cache_enabled?, true
  end

  def test_shoud_return_false_when_global_disbaled
    old = SecondLevelCache.enabled?
    SecondLevelCache.configure.enabled = false
    assert_equal User.second_level_cache_enabled?, false
    SecondLevelCache.configure.enabled = old
  end

  def test_should_return_false
    assert_equal SecondLevelCache.enabled?, true
    User.without_second_level_cache do
      assert_equal User.second_level_cache_enabled?, false
    end
  end

  def test_should_skip_read_cache_when_global_disbaled
    old = SecondLevelCache.enabled?
    SecondLevelCache.configure.enabled = false
    assert_queries(1) do
      result = User.find(@user.id)
      assert_equal @user, result
    end
    SecondLevelCache.configure.enabled = old
  end
end
