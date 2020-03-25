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
    assert Contribution.send(:cache_uniq_key, user_id: 1, date: Date.today), "uniq_key_Contribution_user_id_1,date_#{Date.today.to_s}"
  end

  def test_compare_record_attributes_with_where_values
    book = Book.new(title: 'foobar')
    assert Book.send(:compare_record_attributes_with_where_values, book, title: :foobar)
    book.discount_percentage = 60.00
    assert Book.send(:compare_record_attributes_with_where_values, book, discount_percentage: '60')
    book.publish_date = Date.today
    assert Book.send(:compare_record_attributes_with_where_values, book, publish_date: Date.today.to_s)
    book.title = nil
    assert Book.send(:compare_record_attributes_with_where_values, book, title: nil)
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

  def test_should_return_correct_when_destroy_old_record_and_create_same_new_record
    savepoint do
      uniq_key = { email: "#{Time.now.to_i}@foobar.com" }
      old_user = User.create(uniq_key)
      new_user = old_user.deep_dup
      assert_equal old_user, User.fetch_by_uniq_keys(uniq_key)
      old_user.destroy

      # Dirty id cache should be removed
      assert_queries(2) { assert_nil User.fetch_by_uniq_keys(uniq_key) }
      assert_queries(1) { assert_nil User.fetch_by_uniq_keys(uniq_key) }

      new_user.save
      assert_equal new_user, User.fetch_by_uniq_keys(uniq_key)
    end
  end

  def test_should_return_correct_when_old_record_modify_uniq_key_and_new_record_use_same_uniq_key
    savepoint do
      uniq_key = { email: @user.email }
      assert_equal @user, User.fetch_by_uniq_keys(uniq_key)
      @user.update_attribute(:email, "#{Time.now.to_i}@foobar.com")
      new_user = User.create(uniq_key)
      assert_equal new_user, User.fetch_by_uniq_keys(uniq_key)
    end
  end
end
