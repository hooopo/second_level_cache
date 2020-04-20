# frozen_string_literal: true

require "test_helper"

class PreloaderBelongsToTest < ActiveSupport::TestCase
  def test_preload_caches_includes
    topics = [
      Topic.create(title: "title1", body: "body1"),
      Topic.create(title: "title2", body: "body2"),
      Topic.create(title: "title3", body: "body3")
    ]
    topics.each { |topic| topic.posts.create(body: "post#{topic.id}") }

    results = nil
    assert_queries(1) do
      results = Post.includes(:topic).order("id ASC").to_a
    end
    assert_equal topics, results.map(&:topic)
  end

  def test_when_read_multi_missed_from_cache_ar_will_fetch_missed_records_from_db
    topics = [
      Topic.create(title: "title1", body: "body1"),
      Topic.create(title: "title2", body: "body2"),
      Topic.create(title: "title3", body: "body3")
    ]
    topics.each { |topic| topic.posts.create(body: "post#{topic.id}") }
    expired_topic = topics.first
    expired_topic.expire_second_level_cache

    results = nil
    assert_queries(2) do
      assert_sql(/WHERE\s\"topics\"\.\"id\"\s=\s?/m) do
        results = Post.includes(:topic).order("id ASC").to_a
        assert_equal expired_topic, results.first.topic
      end
    end

    assert_equal topics, results.map(&:topic)
  end

  def test_preloader_caches_includes_tried_set_inverse_instance
    user_id = Time.current.to_i
    Account.create(site: "foobar", user_id: user_id)
    User.create(id: user_id, name: "foobar", email: "foobar@test.com")
    accounts = Account.includes(:user)
    assert_equal accounts.first.object_id, accounts.first.user.account.object_id
  end

  def test_preloader_from_db_when_exists_scope
    user = User.create
    book = user.books.create
    image = book.images.create
    book.toggle!(:normal)
    assert_queries(:any) do
      assert_nil Image.includes(:imagable).where(id: image.id).first.imagable
    end
  end
end
