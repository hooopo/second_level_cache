# -*- encoding : utf-8 -*-
ActiveRecord::Base.connection.create_table(:images, :force => true) do |t|
  t.string  :url
  t.string  :imagable_type
  t.integer :imagable_id
end

class Image < ActiveRecord::Base
  acts_as_cached

  belongs_to :imagable, :polymorphic => true, :counter_cache => true
end

