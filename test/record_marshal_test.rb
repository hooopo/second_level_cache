# -*- encoding : utf-8 -*-
require 'active_record/test_helper'

class RecordMarshalTest < Test::Unit::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
  end

  def test_should_dump_active_record_object
    dumped = RecordMarshal.dump(@user)
    assert dumped.is_a?(Array)
    assert_equal "User", dumped[0]
    assert_equal @user.attributes, dumped[1]
  end


  def test_should_load_active_record_object
    @user.write_second_level_cache
    assert_equal @user, User.read_second_level_cache(@user.id)
  end


  def test_should_load_nil
    @user.expire_second_level_cache
    assert_nil User.read_second_level_cache(@user.id)
  end

  def test_should_load_active_record_object_without_association_cache
    @user.books
    @user.write_second_level_cache
    assert_empty User.read_second_level_cache(@user.id).association_cache
  end
end
