ActiveRecord::Base.connection.create_table(:images, force: true) do |t|
  t.string  :url
  t.string  :imagable_type
  t.integer :imagable_id
end

class Image < ActiveRecord::Base
  second_level_cache

  belongs_to :imagable, polymorphic: true, counter_cache: true
end
