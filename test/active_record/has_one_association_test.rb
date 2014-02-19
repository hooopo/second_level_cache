# -*- encoding : utf-8 -*-
require 'active_record/test_helper'

class ActiveRecord::HasOneAssociationTest < Minitest::Test
  def setup
    @user = User.create :name => 'hooopo', :email => 'hoooopo@gmail.com'
    @account = @user.create_account
  end

  def test_should_fetch_account_from_cache
    clean_user = @user.reload
    no_connection do
      clean_user.account
    end
  end
end
