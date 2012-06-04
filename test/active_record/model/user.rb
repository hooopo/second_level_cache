ActiveRecord::Base.connection.create_table(:users, :force => true) do |t|
  t.string  :name
  t.string  :email
  t.integer :books_count, :default => 0
end

class User < ActiveRecord::Base
  acts_as_cached

  has_many :books
end
