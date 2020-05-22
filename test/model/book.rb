# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:books, force: true) do |t|
  t.string  :title
  t.string  :body
  t.integer :user_id
  t.decimal :discount_percentage, precision: 5, scale: 2
  t.integer :images_count, default: 0
  t.date    :publish_date
  t.boolean :normal, default: true, nil: false
end

class Book < ApplicationRecord
  second_level_cache

  default_scope -> { where(normal: true) }

  belongs_to :user, counter_cache: true
  has_many :images, as: :imagable
end
