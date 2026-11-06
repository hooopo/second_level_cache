# frozen_string_literal: true

require "test_helper"

class ParanoidTest < ActiveSupport::TestCase
  def setup
    skip unless defined?(Paranoid)
    @paranoid = Paranoid.create
  end

  def test_should_expire_cache_when_destroy
    skip unless defined?(Paranoid)

    cache_key = @paranoid.second_level_cache_key
    assert_not_nil SecondLevelCache.cache_store.read(cache_key)

    writes = []
    @paranoid.singleton_class.prepend(Module.new do
      define_method(:write_second_level_cache) do
        writes << [deleted?, deleted_at]
        super()
      end
    end)

    @paranoid.destroy

    assert @paranoid.deleted?
    assert_nil Paranoid.find_by(id: @paranoid.id)
    # Soft-delete is an update. The writer may run from after_commit, but it
    # must return before storing a row whose deleted_at is set.
    writes.each do |was_deleted, deleted_at|
      assert was_deleted, "write_second_level_cache ran for a live row during soft-delete"
      assert deleted_at
    end
    assert_nil SecondLevelCache.cache_store.read(cache_key)

    @paranoid.write_second_level_cache
    assert_nil SecondLevelCache.cache_store.read(cache_key)
  end
end
