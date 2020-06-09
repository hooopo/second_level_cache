# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Core
      extend ActiveSupport::Concern
      included do
        singleton_class.delegate :find, :find_by, :find_by!, to: :all
      end
    end
  end
end
