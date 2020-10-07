# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:posts, force: true) do |t|
  t.text :body
  t.string :slug
  t.integer :topic_id
end

ActiveRecord::Base.connection.create_table(:hotspots, force: true) do |t|
  t.integer :post_id
  t.string :summary
end

class Post < ApplicationRecord
  second_level_cache
  belongs_to :topic, touch: true
end

class Hotspot < ApplicationRecord
  belongs_to :post, required: false
  has_one :topic, through: :post
end
