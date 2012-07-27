# -*- encoding : utf-8 -*-
ActiveRecord::Base.connection.create_table(:topics, :force => true) do |t|
  t.string  :title
  t.text  :body

  t.timestamps
end

class Topic < ActiveRecord::Base
  acts_as_cached

  has_many :posts
end
