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
end
