require 'test_helper'

class HasOneAssociationTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: 'hooopo', email: 'hoooopo@gmail.com'
    @account = @user.create_account
  end

  def test_should_fetch_account_from_cache
    clean_user = @user.reload
    assert_no_queries do
      clean_user.account
    end
  end

  def test_should_fetch_has_one_through
    user = User.create name: 'hooopo', email: 'hoooopo@gmail.com', forked_from_user: @user
    clean_user = user.reload
    assert_equal User, clean_user.forked_from_user.class
    assert_equal @user.id, user.forked_from_user.id
    # clean_user = user.reload
    # assert_no_queries do
    #   clean_user.forked_from_user
    # end
  end

  def test_has_one_with_conditions
    user = User.create name: 'hooopo', email: 'hoooopo@gmail.com'
    Namespace.create(user_id: user.id, name: 'ruby-china', kind: 'group')
    user.create_namespace(name: 'hooopo')
    Namespace.create(user_id: user.id, name: 'rails', kind: 'group')
    assert_not_equal user.namespace, nil
    clear_user = User.find(user.id)
    assert_equal clear_user.namespace.name, 'hooopo'
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
end
