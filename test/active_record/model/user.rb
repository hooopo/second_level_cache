# -*- encoding : utf-8 -*-
ActiveRecord::Base.connection.create_table(:users, :force => true) do |t|
  t.string  :name
  t.string  :email
  t.integer :books_count, :default => 0
  t.integer :images_count, :default => 0
end

class User < ActiveRecord::Base
  acts_as_cached

  has_many :books
  has_many :images, :as => :imagable
end
