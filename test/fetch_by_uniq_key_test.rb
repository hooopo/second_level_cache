# frozen_string_literal: true

require "test_helper"

class FetchByUinqKeyTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: "hooopo", email: "hoooopo@gmail.com"
    @post = Post.create slug: "foobar", topic_id: 2
  end

  def test_cache_uniq_key
    assert_equal User.send(:cache_uniq_key, name: "hooopo"), "uniq_key_User_name_hooopo"
    assert_equal User.send(:cache_uniq_key, foo: 1, bar: 2), "uniq_key_User_foo_1,bar_2"
    assert_equal User.send(:cache_uniq_key, foo: 1, bar: nil), "uniq_key_User_foo_1,bar_"
    long_val = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    assert_equal User.send(:cache_uniq_key, foo: 1, bar: long_val), "uniq_key_User_foo_1,bar_#{Digest::MD5.hexdigest(long_val)}"
  end

  def test_should_query_from_db_using_primary_key
    Post.fetch_by_uniq_keys(topic_id: 2, slug: "foobar")
    @post.expire_second_level_cache
    assert_sql(/SELECT\s+"posts".* FROM "posts"\s+WHERE "posts"."id" = \? LIMIT ?/) do
      Post.fetch_by_uniq_keys(topic_id: 2, slug: "foobar")
    end
  end

  def test_should_not_hit_db_using_fetch_by_uniq_key_twice
    post = Post.fetch_by_uniq_keys(topic_id: 2, slug: "foobar")
    assert_equal post, @post
    assert_no_queries do
      Post.fetch_by_uniq_keys(topic_id: 2, slug: "foobar")
    end
  end

  def test_should_fail_when_fetch_by_uniq_key_with_bang_method
    assert_raises(ActiveRecord::RecordNotFound) do
      Post.fetch_by_uniq_keys!(topic_id: 2, slug: "foobar1")
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      User.fetch_by_uniq_key!("xxxxx", :name)
    end
  end

  def test_should_return_nil_when_record_not_found
    assert_not_nil Post.fetch_by_uniq_keys(topic_id: 2, slug: "foobar")
    assert_nil Post.fetch_by_uniq_keys(topic_id: 3, slug: "foobar")
  end

  def test_should_work_with_fetch_by_uniq_key
    user = User.fetch_by_uniq_key(@user.name, :name)
    assert_equal user, @user
  end

  def test_should_hit_db_using_fetch_by_uniq_key_after_update_uniq_key
    post_old = Post.create slug: "foobar111", topic_id: 2, user_id: 1, iid: 1
    assert_queries do
      Post.fetch_by_uniq_keys(user_id: 1, iid: 1)
    end
    post_old.update_attributes!(iid: 11)
    assert_nil Post.fetch_by_uniq_keys(user_id: 1, iid: 1)
    post = Post.create slug: "foobar222", topic_id: 3, user_id: 1, iid: 1
    post_cache = Post.fetch_by_uniq_keys(user_id: 1, iid: 1)
    assert_equal post, post_cache
    assert_queries do
      Post.fetch_by_uniq_keys(user_id: 1, iid: 11)
    end
  end

  def test_should_hit_db_using_fetch_by_uniq_key_after_rebuild_record
    post_old = Post.create slug: "foobar333", topic_id: 5, user_id: 2, iid: 2
    assert_queries do
      Post.fetch_by_uniq_keys(user_id: 2, iid: 2)
    end
    post_old.destroy
    assert_nil Post.fetch_by_uniq_keys(user_id: 2, iid: 2)
    post_new = Post.create slug: "foobar444", topic_id: 5, user_id: 2, iid: 2
    post_cache = Post.fetch_by_uniq_keys(user_id: 2, iid: 2)
    assert_equal post_new, post_cache
  end
end
