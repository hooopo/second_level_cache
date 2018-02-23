require 'test_helper'
require 'active_record'

class RequireTest < ActiveSupport::TestCase
  def setup
    ActiveRecord::Relation.new(nil, table: nil, predicate_builder: nil)
    require 'test_helper'
    @user = User.create name: 'Dingding Ye', email: 'yedingding@gmail.com'
  end

  def test_should_find_the_user
    assert_equal @user, User.find(@user.id)
  end
end
