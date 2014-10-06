# -*- encoding : utf-8 -*-
ActiveRecord::Base.connection.create_table(:animals, force: true) do |t|
  t.string  :type
  t.string  :name
  t.timestamps null: false
end

class Animal < ActiveRecord::Base
  acts_as_cached
end

class Dog < Animal
  acts_as_cached
end
