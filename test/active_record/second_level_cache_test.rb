require 'active_record/test_helper'

class ActiveRecord::SecondLevelCacheTest < Test::Unit::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
  end

  def teardown
    User.delete_all
  end

  def test_should_get_cache_key
    assert_equal "User/#{@user.id}", @user.second_level_cache_key
  end

  def test_should_write_and_read_cache
    assert_not_nil User.read_second_level_cache(@user.id)
    @user.expire_second_level_cache
    assert_nil User.read_second_level_cache(@user.id)
    @user.write_second_level_cache
    assert_not_nil User.read_second_level_cache(@user.id)
  end

  def test_should_have_cache_when_create
    no_connection do
      assert_not_nil User.read_second_level_cache(@user.id)
      assert_equal @user, User.find(@user.id)
    end
  end

  def test_should_update_cache_when_update
    @user.update_attributes :name => 'change'

    no_connection do
      assert_equal 'change', User.find(@user.id).name
    end
  end

  def test_should_get_cache_when_use_singular_association
    book = @user.books.create

    no_connection do
      assert_equal @user, book.user
    end
  end

  def test_should_write_singular_association_cache
    book = @user.books.create
    @user.expire_second_level_cache
    assert_nil User.read_second_level_cache(@user.id)
    assert_equal @user, book.user
    assert_not_nil User.read_second_level_cache(@user.id)
  end

  def test_should_expire_cache_when_destroy
    @user.destroy
    assert_nil User.read_second_level_cache(@user.id)
  end
end
