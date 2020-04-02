# frozen_string_literal: true

require "test_helper"

class BelongsToAssociationTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: "csdn", email: "test@csdn.com"
  end

  def test_should_get_cache_when_use_belongs_to_association
    book = @user.books.create

    @user.write_second_level_cache
    book.send(:clear_association_cache)
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

  def test_should_expire_changed_association_uniq_keys_when_foreign_key_is_symbol
    reflection = Account.reflect_on_association(:user)
    assert reflection.belongs_to?
    assert reflection.foreign_key.is_a?(Symbol)

    account = @user.create_account(site: "foobar")
    @user.reload.account # Write cache
    cache_key = Account.send(:cache_uniq_key, reflection.foreign_key => @user.id)
    assert_equal @user.id, SecondLevelCache.cache_store.read(cache_key)

    account.update_attribute(:user_id, 0)
    assert_equal nil, SecondLevelCache.cache_store.read(cache_key)
  end
end
