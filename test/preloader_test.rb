# frozen_string_literal: true

require "test_helper"

class PreloaderTest < ActiveSupport::TestCase
  def test_belongs_to_preload_caches_includes
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

  def test_belongs_to_when_read_multi_missed_from_cache_ar_will_fetch_missed_records_from_db
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

  def test_has_one_preload_caches_includes
    users = User.create([
                          { name: "foobar1", email: "foobar1@test.com" },
                          { name: "foobar2", email: "foobar2@test.com" },
                          { name: "foobar3", email: "foobar3@test.com" }
                        ])
    namespaces = users.map { |user| user.create_namespace(name: user.name) }

    assert_queries(2) { User.includes(:namespace).order(id: :asc).to_a }  # Write cache
    assert_queries(1) do
      assert_equal namespaces, User.includes(:namespace).order(id: :asc).map(&:namespace)
    end
  end

  def test_has_one_when_read_multi_missed_from_cache_should_will_fetch_missed_records_from_db
    users = User.create([
                          { name: "foobar1", email: "foobar1@test.com" },
                          { name: "foobar2", email: "foobar2@test.com" },
                          { name: "foobar3", email: "foobar3@test.com" }
                        ])
    namespaces = users.map { |user| user.create_namespace(name: user.name) }
    assert_queries(2) { User.includes(:namespace).order(id: :asc).to_a }  # Write cache
    expired_namespace = namespaces.first
    expired_namespace.expire_second_level_cache

    assert_queries(2) do
      assert_sql(/WHERE\s\"namespaces\".\"kind\"\sIS\sNULL\sAND\s\"namespaces\"\.\"user_id\"\s=\s?/m) do
        results = User.includes(:namespace).order(id: :asc).to_a
        assert_equal namespaces, results.map(&:namespace)
        assert_equal expired_namespace, results.first.namespace
      end
    end
  end

  def test_has_one_preloader_returns_correct_records_after_modify
    user = User.create(name: "foobar", email: "foobar@test.com")

    old_namespace = user.create_namespace(name: "old")
    assert_queries(2) { User.includes(:namespace).order(id: :asc).to_a }  # Write cache
    assert_queries(1) do
      assert_equal old_namespace, User.includes(:namespace).first.namespace
    end

    new_namespace = user.create_namespace(name: "new")
    assert_queries(2) { User.includes(:namespace).order(id: :asc).to_a }  # Write cache
    assert_queries(1) do
      assert_equal new_namespace, User.includes(:namespace).first.namespace
    end
  end

  def test_has_one_preloader_caches_includes_tried_set_inverse_instance
    User.create(name: "foobar", email: "foobar@test.com").create_account(site: "foobar")
    users = User.includes(:account)
    assert_equal users.first.object_id, users.first.account.user.object_id
  end

  def test_has_many_preloader_returns_correct_results
    topic = Topic.create(id: 1)
    Post.create(id: 1)
    post = topic.posts.create

    assert_equal [post], Topic.includes(:posts).find(1).posts
  end
end
