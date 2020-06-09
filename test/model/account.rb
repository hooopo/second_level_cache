# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:accounts, force: true) do |t|
  t.integer :age
  t.string :site
  t.integer :user_id
  t.timestamps null: false
end

class Account < ApplicationRecord
  second_level_cache expires_in: 3.days, unique_indexes: [:user_id]
  belongs_to :user, foreign_key: :user_id, inverse_of: :account
end
