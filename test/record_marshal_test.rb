# -*- encoding : utf-8 -*-
require 'test_helper'

class RecordMarshalTest < ActiveSupport::TestCase
  def setup
    @json_options = { "name" => 'Test', "age" => 18 }
    @user = User.create :name => 'csdn',
              :email => 'test@csdn.com',
              :options => [1,2],
              :json_options => @json_options
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
    assert_equal Array, User.read_second_level_cache(@user.id).options.class
    assert_equal Array, User.read_second_level_cache(@user.id).reload.options.class
    assert_equal User.read_second_level_cache(@user.id).changed?, false
    assert_equal [1,2], User.read_second_level_cache(@user.id).options
    result = User.read_second_level_cache(@user.id)
    assert_equal @json_options, result.json_options
    assert User.read_second_level_cache(@user.id).persisted?
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
