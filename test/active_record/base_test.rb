# -*- encoding : utf-8 -*-
require 'active_record/test_helper'

class ActiveRecord::BaseTest < Test::Unit::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
  end

  def test_should_have_cache_when_create
    no_connection do
      assert_not_nil User.read_second_level_cache(@user.id)
      assert_equal @user, User.find(@user.id)
    end
  end

  def test_should_update_cache_when_update
    @user.update_attributes :name => 'change'

    no_connection do
      assert_equal 'change', User.find(@user.id).name
    end

    assert_equal 'change', @user.reload.name
  end

  def test_should_expire_cache_when_destroy
    @user.destroy
    assert_nil User.read_second_level_cache(@user.id)
  end

  def test_should_expire_cache_when_update_counters
    assert_equal @user.books_count, 0
    @user.books.create
    assert_nil User.read_second_level_cache(@user.id)
    user = User.find(@user.id)
    assert_equal user.books_count, @user.books_count + 1
  end

  def test_should_clear_association_cache_before_write_cache
    topic = Topic.create :title => 'title', :body => 'text'
    p = Post.create :topic => topic, :body => 'body'
    topic.update_column :body, 'change'
    assert_equal 'change', Post.read_second_level_cache(p.id).topic.body
    assert Post.read_second_level_cache(p.id).association_cache.empty?
  end

  def test_should_have_no_changed_attributes_when_read_from_cache
    @user.update_attribute :name, 'change'
    assert !User.find(@user.id).changed?, "should be clear"
  end
end
