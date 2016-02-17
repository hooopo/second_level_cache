# -*- encoding : utf-8 -*-
require 'test_helper'

class PersistenceTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: 'csdn', email: 'test@csdn.com'
    @topic = Topic.create title: "csdn"
  end

  def test_should_reload_object
    User.where(id: @user.id).update_all(email: 'different@csdn.com')
    assert_equal 'different@csdn.com', @user.reload.email
  end

  def test_should_reload_object_associations
    User.increment_counter :books_count, @user.id
    assert_equal 0, @user.books_count
    assert_equal 1, @user.reload.books_count
  end

  def test_should_update_cache_after_touch
    old_updated_time = @user.updated_at
    @user.touch
    assert !(old_updated_time == @user.updated_at)
    new_user = User.find @user.id
    assert_equal new_user, @user
  end

  def test_should_update_cache_after_update_column
    @user.update_column :name, "new_name"
    new_user = User.find @user.id
    assert_equal new_user, @user
  end

  def test_should_return_true_if_touch_ok
    assert @topic.touch == true
  end
end
