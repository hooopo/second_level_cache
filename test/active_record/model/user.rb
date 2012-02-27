ActiveRecord::Base.connection.create_table(:users, :force => true) do |t|
  t.string :name
  t.string :email
end

class User < ActiveRecord::Base
  acts_as_cached

  has_many :books
end
