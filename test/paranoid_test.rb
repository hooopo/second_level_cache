# frozen_string_literal: true

require "test_helper"

class ParanoidTest < ActiveSupport::TestCase
  def setup
    @paranoid = Paranoid.create
  end

  def test_should_expire_cache_when_destroy
    @paranoid.destroy
    assert_nil Paranoid.find_by(id: @paranoid.id)
    assert_nil SecondLevelCache.cache_store.read(@paranoid.second_level_cache_key)
    assert_nil User.read_second_level_cache(@paranoid.id)
  end
end
