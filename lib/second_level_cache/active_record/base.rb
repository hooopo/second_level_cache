# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module Base
      def self.prepended(base)
        base.after_commit :update_second_level_cache, on: :update
        base.after_commit :write_second_level_cache, on: :create
        if defined?(::Paranoia)
          base.after_destroy :expire_second_level_cache
        else
          base.after_commit :expire_second_level_cache, on: :destroy
        end

        class << base
          prepend ClassMethods
        end
      end

      module ClassMethods
        def update_counters(id, counters)
          super(id, counters).tap do
            Array(id).each { |i| expire_second_level_cache(i) }
          end
        end
      end
    end
  end
end
