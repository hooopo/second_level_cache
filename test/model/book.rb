# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:books, force: true) do |t|
  t.string  :title
  t.string  :body
  t.integer :user_id
  t.decimal :discount_percentage, precision: 5, scale: 2
  t.integer :images_count, default: 0
  t.date    :publish_date
end

class Book < ActiveRecord::Base
  second_level_cache

  belongs_to :user, counter_cache: true
  has_many :images, as: :imagable
end
