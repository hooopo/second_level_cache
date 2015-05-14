# -*- encoding : utf-8 -*-
require 'test_helper'

class HasOneAssociationTest < ActiveSupport::TestCase
  def setup
    @user = User.create :name => 'hooopo', :email => 'hoooopo@gmail.com'
    @account = @user.create_account
    UserProfile.create()
    @profile = @user.create_profile
  end

  def test_should_fetch_account_from_cache
    clean_user = @user.reload
    assert_no_queries do
      clean_user.account
    end
    assert_no_queries do
      clean_user.profile
    end
    assert_queries(1) do
      User.includes(:profile).find(@user.id).profile
    end
  end
end
