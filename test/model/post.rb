# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:posts, force: true) do |t|
  t.text :body
  t.string :slug
  t.integer :topic_id
  t.integer :user_id
  t.integer :iid
end

class Post < ActiveRecord::Base
  second_level_cache
  belongs_to :topic, touch: true
end
