# frozen_string_literal: true

require "test_helper"

class BelongsToAssociationTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: "csdn", email: "test@csdn.com"
  end

  def test_should_get_cache_when_use_belongs_to_association
    book = @user.books.create

    @user.write_second_level_cache

    assert_no_queries do
      assert_equal @user, book.user
    end
  end

  def test_should_write_belongs_to_association_cache
    book = @user.books.create
    @user.expire_second_level_cache
    assert_nil User.read_second_level_cache(@user.id)
    assert_equal @user, book.user
    # assert_not_nil User.read_second_level_cache(@user.id)
  end

  def test_rails_8_find_target_accepts_async_keyword
    skip "Rails 8 find_target(async:)" unless ActiveRecord.gem_version >= Gem::Version.new("8.0")

    book = @user.books.create
    @user.write_second_level_cache
    fresh = Book.find(book.id)
    association = fresh.association(:user)

    assert_no_queries do
      assert_equal @user, association.send(:find_target, async: false)
    end

    association.reset
    # ActiveRecord::Promise is a BasicObject, so it has no #tap. Do not wrap
    # this call in assert_nothing_raised, which taps the block result.
    async_result = association.send(:find_target, async: true)
    resolved = resolve_async_target(async_result)
    assert_equal @user.id, resolved.id

    association.reset
    assert_nil association.async_load_target
    assert_equal @user, fresh.user
  end
end
