# frozen_string_literal: true

require "test_helper"
require "active_record"

class RequireTest < ActiveSupport::TestCase
  def setup
    # Rails 7.2 Relation#initialize dereferences the model when table is omitted.
    if ActiveRecord.gem_version < Gem::Version.new("7.2")
      ActiveRecord::Relation.new(nil, table: nil, predicate_builder: nil)
    end
    require "test_helper"
    @user = User.create name: "Dingding Ye", email: "yedingding@gmail.com"
  end

  def test_should_find_the_user
    assert_equal @user, User.find(@user.id)
  end
end
