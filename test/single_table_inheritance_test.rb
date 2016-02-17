require 'test_helper'

class SingleTableInheritanceTest < ActiveSupport::TestCase
  def test_superclass_find__caches_superclass_record
    animal = Animal.create
    assert_no_queries do
      assert_equal animal, Animal.find(animal.id)
    end
  end

  def test_superclass_find__caches_subclass_record
    dog = Dog.create
    assert_no_queries do
      assert_equal dog, Animal.find(dog.id)
    end
  end

  def test_subclass_find__caches_subclass_record
    dog = Dog.create
    dog_id = dog.id
    assert_no_queries do
      newdog = Dog.find(dog_id)
      assert_equal dog, newdog
    end
  end

  def test_subclass_find__doesnt_find_superclass_record
    animal = Animal.create
    assert_queries(:any) do
      assert_raises ActiveRecord::RecordNotFound do
        Dog.find(animal.id)
      end
    end
  end
end
