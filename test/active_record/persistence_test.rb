# -*- encoding : utf-8 -*-
require 'active_record/test_helper'

class ActiveRecord::PersistenceTest < Test::Unit::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
    @topic = Topic.create :title => "csdn"
  end

  def test_should_reload_object
    User.increment_counter :books_count, @user.id
    assert_equal 0, @user.books_count
    assert_equal 1, @user.reload.books_count
  end

  def test_should_clean_cache_after_touch
    post = @topic.posts.create
    post.body = "body"
    post.save
    new_topic = Topic.find @topic.id
    assert !(new_topic.updated_at == @topic.updated_at)
  end

  def test_should_return_true_if_touch_ok
    assert @topic.touch == true
  end
end
