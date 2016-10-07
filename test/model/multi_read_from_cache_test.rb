# -*- encoding : utf-8 -*-
require 'test_helper'

class MultiReadFromCacheTest < ActiveSupport::TestCase
  def setup
    @user = User.create :name => 'hooopo', :email => 'hoooopo@gmail.com'
    @other_user = User.create :name => 'hoooopo', :email => "hooooopo@gmail.com"
  end

  def test_multi_read_from_cache
    result = User.multi_read_from_cache([@user.id, @other_user.id])
    assert_equal 2, result.size
  end

  def test_multi_read_not_exist_id_from_cache
    result = User.multi_read_from_cache([@user.id, @other_user.id + 100])
    assert_equal 1, result.size
  end
end
