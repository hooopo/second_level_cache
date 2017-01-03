ActiveRecord::Base.connection.create_table(:books, force: true) do |t|
  t.string  :title
  t.string  :body
  t.integer :user_id
  t.integer :images_count, default: 0
end

class Book < ActiveRecord::Base
  second_level_cache

  belongs_to :user, counter_cache: true
  has_many :images, as: :imagable
end
