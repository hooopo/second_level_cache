# frozen_string_literal: true

require "test_helper"

class HasOneAssociationTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: "hooopo", email: "hoooopo@gmail.com"
    @account = @user.create_account
  end

  def test_should_fetch_account_from_cache
    clean_user = @user.reload
    assert_no_queries do
      clean_user.account
    end
  end

  def test_should_fetch_has_one_through
    user = User.create name: "hooopo", email: "hoooopo@gmail.com", forked_from_user: @user
    clean_user = user.reload
    assert_equal User, clean_user.forked_from_user.class
    assert_equal @user.id, user.forked_from_user.id
    # If ForkedUserLink second_level_cache_enabled is true
    user.reload
    assert_no_queries do
      user.forked_from_user
    end
    # IF ForkedUserLink second_level_cache_enabled is false
    user.reload
    ForkedUserLink.without_second_level_cache do
      assert_queries(1) { user.forked_from_user }
    end
    # NoMethodError: undefined method `klass' for nil:NilClass  active_record/has_one_association.rb:14:in `find_target'
    hotspot = Hotspot.create(summary: "summary")
    assert_equal hotspot.persisted?, true
    assert_nil hotspot.topic
  end

  def test_has_one_with_conditions
    user = User.create name: "hooopo", email: "hoooopo@gmail.com"
    Namespace.create(user_id: user.id, name: "ruby-china", kind: "group")
    user.create_namespace(name: "hooopo")
    Namespace.create(user_id: user.id, name: "rails", kind: "group")
    assert_not_equal user.namespace, nil
    clear_user = User.find(user.id)
    assert_equal clear_user.namespace.name, "hooopo"
  end

  def test_assign_relation
    assert_equal @user.account, @account
    new_account = Account.create
    @user.account = new_account
    assert_equal @user.account, new_account
    assert_equal @user.reload.account, new_account
  end

  def test_belongs_to_column_change
    assert_equal @user.account, @account
    @account.update(user_id: @user.id + 1)
    assert_nil @user.reload.account
  end

  def test_should_one_query_when_has_one_target_is_null
    Namespace.destroy_all
    @user.reload
    assert_queries(1) { @user.namespace }
  end

  def test_rails_8_find_target_accepts_async_keyword
    skip "Rails 8 find_target(async:)" unless ActiveRecord.gem_version >= Gem::Version.new("8.0")

    user = User.find(@user.id)
    association = user.association(:account)

    assert_equal @account, association.send(:find_target, async: false)

    association.reset
    # ActiveRecord::Promise is a BasicObject, so it has no #tap. Do not wrap
    # this call in assert_nothing_raised, which taps the block result.
    async_result = association.send(:find_target, async: true)
    resolved = resolve_async_target(async_result)
    assert_equal @account.id, resolved.id

    association.reset
    assert_nil association.async_load_target
    assert_equal @account, user.account
  end
end
