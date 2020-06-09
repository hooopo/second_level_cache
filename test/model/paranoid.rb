# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:paranoids, force: true) do |t|
  t.datetime :deleted_at
end

class Paranoid < ApplicationRecord
  second_level_cache
  acts_as_paranoid
end
