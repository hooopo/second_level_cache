# -*- encoding : utf-8 -*-
ActiveRecord::Base.connection.create_table(:accounts, :force => true) do |t|
  t.integer  :age
  t.string   :site
  t.integer  :user_id
  t.timestamps
end

class Account < ActiveRecord::Base
  acts_as_cached(:expires_in => 3.day)
  belongs_to :user
end