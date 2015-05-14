# -*- encoding : utf-8 -*-
ActiveRecord::Base.connection.create_table(:users, :force => true) do |t|
  t.text    :options
  t.string  :name, :unique => true
  t.string  :email
  t.integer :books_count, :default => 0
  t.integer :images_count, :default => 0
  t.timestamps null: false
end

class User < ActiveRecord::Base
  CacheVersion = 3
  serialize :options, Array
  acts_as_cached(:version => CacheVersion, :expires_in => 3.day)
  has_one  :account
  has_one  :profile, class_name: 'UserProfile', autosave: true
  has_many :books
  has_many :images, :as => :imagable
end
