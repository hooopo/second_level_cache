require 'active_record/test_helper'

class ActiveRecord::PersistenceTest < Test::Unit::TestCase
  def setup
    @user = User.create :name => 'csdn', :email => 'test@csdn.com'
  end

  def test_should_reload_object
    User.increment_counter :books_count, @user.id
    assert_equal 0, @user.books_count
    assert_equal 1, @user.reload.books_count
  end
end
