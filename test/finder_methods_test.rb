# -*- encoding : utf-8 -*-
require 'test_helper'

class FinderMethodsTest < ActiveSupport::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
    @other_user = User.create :name => 'shopper+', :email => 'test@shopperplus.com'
  end

  def test_should_find_without_cache
    SecondLevelCache.cache_store.clear
    assert_equal @user, User.find(@user.id)
  end

  def test_should_find_with_cache
    @user.write_second_level_cache
    assert_no_queries do
      assert_equal @user, User.find(@user.id)
    end
  end

  def test_should_find_with_condition
    @user.write_second_level_cache
    assert_no_queries do
      assert_equal @user, User.where(:name => @user.name).find(@user.id)
    end
  end

  def test_should_NOT_find_from_cache_when_select_speical_columns
    @user.write_second_level_cache
    only_id_user = User.select("id").find(@user.id)
    assert_raises(ActiveModel::MissingAttributeError) do
      only_id_user.name
    end
  end

  def test_without_second_level_cache
    @user.name = "NewName"
    @user.write_second_level_cache
    User.without_second_level_cache do
      @from_db = User.find(@user.id)
    end
    refute_equal @user.name, @from_db.name
  end

  def test_find_some_record
    @users = User.find(@user.id, @other_user.id)
    assert_equal 2, @users.size
  end

  def test_find_some_record_without_second_level_cache
    User.without_second_level_cache do
      @users = User.find(@user.id, @other_user.id)
    end
    assert_equal 2, @users.size
  end

  def test_missing_id_will_raise_for_find_some
    assert_raises(ActiveRecord::RecordNotFound) do
      @users = User.find(@user.id, User.last.id + 10000)
    end
  end

  def test_filter_works_fine_for_find_some
    assert_raises(ActiveRecord::RecordNotFound) do
      @users = User.where("name is null").find(@user.id, @other_user.id)
    end
  end

  def test_half_in_cache_for_find_some
    @user.expire_second_level_cache
    @users = User.find(@user.id, @other_user.id)
    assert_equal 2, @users.size
  end

  def test_no_record_in_cache_for_find_some
    @user.expire_second_level_cache
    @other_user.expire_second_level_cache
    @users = User.find(@user.id, @other_user.id)
    assert_equal 2, @users.size
  end
end
