ActiveRecord::Base.connection.create_table(:orders, force: true, id: :uuid) do |t|
  t.text :body
  t.string :title

  t.timestamps null: false
end

class Order < ActiveRecord::Base
  second_level_cache

  has_many :order_items
end
