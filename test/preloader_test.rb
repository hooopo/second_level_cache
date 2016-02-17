# -*- encoding : utf-8 -*-
require 'test_helper'

class PreloaderTest < ActiveSupport::TestCase
  def test_belongs_to_preload_caches_includes
    topics = [
      Topic.create(title: 'title1', body: 'body1'),
      Topic.create(title: 'title2', body: 'body2'),
      Topic.create(title: 'title3', body: 'body3')
    ]
    topics.each { |topic| topic.posts.create(body: "post#{topic.id}") }

    results = nil
    assert_queries(1) do
      results = Post.includes(:topic).order('id ASC').to_a
    end
    assert_equal topics, results.map(&:topic)
  end

  def test_belongs_to_when_read_multi_missed_from_cache_AR_will_fetch_missed_records_from_db
    topics = [
      Topic.create(title: 'title1', body: 'body1'),
      Topic.create(title: 'title2', body: 'body2'),
      Topic.create(title: 'title3', body: 'body3')
    ]
    topics.each { |topic| topic.posts.create(body: "post#{topic.id}") }
    expired_topic = topics.first
    expired_topic.expire_second_level_cache

    results = nil
    assert_queries(2) do
      assert_sql(/WHERE\s\"topics\"\.\"id\"\s=\s#{expired_topic.id}/m) do
        results = Post.includes(:topic).order('id ASC').to_a
      end
    end

    assert_equal topics, results.map(&:topic)
  end

  def test_has_many_preloader_returns_correct_results
    topic = Topic.create(id: 1)
    Post.create(id: 1)
    post = topic.posts.create

    assert_equal [post], Topic.includes(:posts).find(1).posts
  end

  def test_has_one_preloader_returns_correct_results
    user = User.create(id: 1)
    Account.create(id: 1)
    account = user.create_account

    assert_equal account, User.includes(:account).find(1).account
  end
end
