# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:animals, force: true) do |t|
  t.string  :type
  t.string  :name
  t.timestamps null: false
end

class Animal < ActiveRecord::Base
  second_level_cache
end

class Dog < Animal
  second_level_cache
end
