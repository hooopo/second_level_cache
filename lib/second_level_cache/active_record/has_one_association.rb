# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Associations
      module HasOneAssociation
        private def skip_statement_cache?(scope)
          klass.second_level_cache_enabled? || super
        end
      end
    end
  end
end
