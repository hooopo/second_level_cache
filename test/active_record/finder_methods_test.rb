# -*- encoding : utf-8 -*-
require 'active_record/test_helper'

class ActiveRecord::FinderMethodsTest < Test::Unit::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
  end

  def test_should_find_without_cache
    SecondLevelCache.cache_store.clear
    assert_equal @user, User.find(@user.id)
  end

  def test_should_find_with_cache
    @user.write_second_level_cache
    no_connection do
      assert_equal @user, User.find(@user.id)
    end
  end

  def test_should_find_with_condition
    @user.write_second_level_cache
    no_connection do
      assert_equal @user, User.where(:name => @user.name).find(@user.id)
    end
  end

  def test_should_NOT_find_from_cache_when_select_speical_columns
    @user.write_second_level_cache
    only_id_user = User.select("id").find(@user.id)
    assert_raise(ActiveModel::MissingAttributeError) do
      only_id_user.name
    end
  end

  def test_without_second_level_cache
    @user.name = "NewName"
    @user.write_second_level_cache
    User.without_second_level_cache do
      @from_db = User.find(@user.id)
    end
    assert_not_equal @user.name, @from_db.name
  end
end
