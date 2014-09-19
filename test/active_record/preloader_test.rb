# -*- encoding : utf-8 -*-
require 'active_record/test_helper'

class ActiveRecord::PreloaderTest < ActiveRecord::TestCase
  def setup
    @topic1 = Topic.create :title => "title1", :body => "body1"
    @topic2 = Topic.create :title => "title2", :body => "body2"
    @topic3 = Topic.create :title => "title3", :body => "body3"
    @post1 = @topic1.posts.create :body => "post1"
    @post2 = @topic2.posts.create :body => "post2"
    @post3 = @topic3.posts.create :body => "post3"
  end

  def test_preload_work_properly
    results = Post.includes(:topic).order("id ASC").to_a
    assert_equal results.size, 3
    assert_equal results.first.topic, @topic1
  end

  def test_when_read_multi_missed_from_cache_AR_will_fetch_missed_records_from_db
    @topic1.expire_second_level_cache

    results = nil
    assert_sql(/IN\s+\(#{@topic1.id}\)/m) do
      results = Post.includes(:topic).order("id ASC").to_a
    end

    assert_equal 3, results.size
    assert_equal @topic1, results.first.topic
  end
end
