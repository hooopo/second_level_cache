ActiveRecord::Base.connection.create_table(:books, :force => true) do |t|
  t.string  :title
  t.string  :body
  t.integer :user_id
end

class Book < ActiveRecord::Base
  acts_as_cached

  belongs_to :user
end
