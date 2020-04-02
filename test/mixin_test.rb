# frozen_string_literal: true

require "test_helper"

class MixinTest < ActiveSupport::TestCase
  def test_should_expire_changed_association_uniq_keys_when_foreign_key_is_symbol
    reflection = Account.reflect_on_association(:user)
    assert reflection.belongs_to?
    assert reflection.foreign_key.is_a?(Symbol)

    user = User.create(name: "foobar", email: "foobar@test.com")
    account = user.create_account(site: "foobar")
    user.reload.account # Write cache
    cache_key = Account.send(:cache_uniq_key, reflection.foreign_key => user.id)
    assert_equal user.id, SecondLevelCache.cache_store.read(cache_key)

    account.update_attribute(:user_id, 0)
    assert_equal nil, SecondLevelCache.cache_store.read(cache_key)
  end
end
