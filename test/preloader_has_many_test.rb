# frozen_string_literal: true

require "test_helper"

class PreloaderHasManyTest < ActiveSupport::TestCase
  def test_preloader_returns_correct_records
    topic = Topic.create(id: 1)
    Post.create(id: 1)
    post = topic.posts.create

    assert_equal [post], Topic.includes(:posts).find(1).posts
  end
end
