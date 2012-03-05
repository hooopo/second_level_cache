require 'active_record/test_helper'

class ActiveRecord::SingularAssociationTest < Test::Unit::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
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
end
