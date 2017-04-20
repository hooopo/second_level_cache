ActiveRecord::Base.connection.create_table(:order_items, force: true, id: :uuid) do |t|
  t.text :body
  t.string :slug
  t.string :order_id
end

class OrderItem < ActiveRecord::Base
  second_level_cache
  belongs_to :order, touch: true
end
