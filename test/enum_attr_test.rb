# frozen_string_literal: true

require "test_helper"

class EnumAttrTest < ActiveSupport::TestCase
  def setup
    @user = User.create name: "csdn", email: "test@csdn.com"
  end

  def test_enum_attr
    @user.archived!
    assert_equal "archived", @user.status
    assert_equal "archived", User.find(@user.id).status
  end
end
