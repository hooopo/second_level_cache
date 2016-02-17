ActiveRecord::Base.connection.create_table(:posts, force: true) do |t|
  t.text :body
  t.string :slug
  t.integer :topic_id
end

class Post < ActiveRecord::Base
  acts_as_cached
  belongs_to :topic, touch: true
end
