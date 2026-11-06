# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:users, force: true) do |t|
  t.text    :options
  t.text    :json_options
  t.text    :extras
  t.string  :name
  t.string  :email
  t.integer :status, default: 0
  t.integer :books_count, default: 0
  t.integer :images_count, default: 0
  t.timestamps null: false, precision: 6
end

ActiveRecord::Base.connection.create_table(:forked_user_links, force: true) do |t|
  t.integer :forked_to_user_id
  t.integer :forked_from_user_id
  t.timestamps null: false
end

ActiveRecord::Base.connection.create_table(:namespaces, force: true) do |t|
  t.integer :user_id
  t.string  :kind
  t.string  :name
  t.timestamps null: false
end

class User < ApplicationRecord
  CACHE_VERSION = 3
  second_level_cache(version: CACHE_VERSION, expires_in: 3.days)

  # Positional serialize coders were removed in Rails 7.2.
  if ActiveRecord.gem_version >= Gem::Version.new("7.1")
    serialize :options, type: Array
    serialize :json_options, coder: JSON
  else
    serialize :options, Array
    serialize :json_options, JSON
  end
  store :extras, accessors: %i[tagline gender]

  has_one  :account, inverse_of: :user
  has_one  :forked_user_link, foreign_key: "forked_to_user_id"
  has_one  :forked_from_user, through: :forked_user_link
  has_many :namespaces
  has_one  :namespace, -> { where(kind: nil) }
  has_many :books
  has_many :images, as: :imagable

  # Keyword enum definitions were removed in Rails 8.0.
  if ActiveRecord.gem_version >= Gem::Version.new("7.0")
    enum :status, %i[active archived]
  else
    enum status: %i[active archived]
  end
end

class Namespace < ApplicationRecord
  second_level_cache version: 1, expires_in: 3.days

  belongs_to :user
end

class ForkedUserLink < ApplicationRecord
  second_level_cache version: 1, expires_in: 1.day

  belongs_to :forked_from_user, class_name: "User"
  belongs_to :forked_to_user, class_name: "User"
end
