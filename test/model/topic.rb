ActiveRecord::Base.connection.create_table(:topics, force: true) do |t|
  t.string  :title
  t.text :body

  t.timestamps null: false
end

class Topic < ActiveRecord::Base
  second_level_cache

  has_many :posts
end
