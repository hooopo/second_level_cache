# -*- encoding : utf-8 -*-
require 'test_helper'

class HasOneAssociationTest < ActiveSupport::TestCase
  def setup
    @user = User.create :name => 'hooopo', :email => 'hoooopo@gmail.com'
    @account = @user.create_account
  end

  def test_should_fetch_account_from_cache
    clean_user = @user.reload
    assert_no_queries do
      clean_user.account
    end
  end

  def test_should_fetch_has_one_through
    user = User.create :name => 'hooopo', :email => 'hoooopo@gmail.com', forked_from_user: @user
    clean_user = user.reload
    assert_equal User, clean_user.forked_from_user.class
    assert_equal @user.id, user.id
    clean_user = user.reload
    assert_no_queries do
      clean_user.forked_from_user
    end
  end
end
