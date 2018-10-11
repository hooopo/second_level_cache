# frozen_string_literal: true

require "test_helper"

class ConfigTest < ActiveSupport::TestCase
  def test_should_return_default_value
    assert_equal SecondLevelCache.enabled?, true
  end

  def test_shoud_write_enabled
    old = SecondLevelCache.enabled?
    SecondLevelCache.configure.enabled = false
    assert_equal SecondLevelCache.enabled?, false
    SecondLevelCache.configure.enabled = old
  end
end
