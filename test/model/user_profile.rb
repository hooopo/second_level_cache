# -*- encoding : utf-8 -*-
ActiveRecord::Base.connection.create_table(:user_profiles, :force => true) do |t|
  t.integer :user_id, null: false
  t.string  :bio
  t.timestamps null: false
end

class UserProfile < ActiveRecord::Base
  CacheVersion = 3
  acts_as_cached(:version => CacheVersion, :expires_in => 3.day)
  belongs_to :user
end
