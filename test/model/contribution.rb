# frozen_string_literal: true

ActiveRecord::Base.connection.create_table(:contributions, force: true) do |t|
  t.integer :user_id
  t.text    :data
  t.date    :date
end

class Contribution < ActiveRecord::Base
  second_level_cache

  validates_uniqueness_of :user_id, scope: :date, if: -> { user_id_changed? || date_changed? }
  belongs_to :user
end
