# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module QueryCache
      extend ActiveSupport::Concern

      private
        def exec_queries(&block)
          @second_level_cache_where_values_hash = where_values_hash
          return super unless exec_queries_cachable?

          record = klass.read_second_level_cache(@second_level_cache_where_values_hash, &block)
          # FIXME: The write_second_level_cache should only be calling when where_values_hash match unique index
          return super.tap { |records| records.first&.write_second_level_cache } unless record

          @records = [record].freeze
          preload_associations(@records) unless skip_preloading_value
          @records.each(&:readonly!) if readonly_value
          @loaded = true
          @records
        end

        # @see ActiveRecord::Relation::VALUE_METHODS
        def exec_queries_cachable?
          klass.second_level_cache_enabled? &&
            !skip_query_cache_value &&
            offset_value.nil? &&
            group_values.empty? &&
            joins_values.empty? &&
            left_outer_joins_values.empty? &&
            !eager_loading? &&
            having_clause.blank? &&
            from_clause.blank? &&
            select_values_cachable? &&
            # order_values_cachable? &&
            # limit_value_cachable? &&
            where_clause_cachable?
        end

        # TODO: implement select values cache
        def select_values_cachable?
          select_values.empty? # || (select_values.map(&:to_s) - klass.column_names).blank?
        end

        # TODO: implement contain single array cache
        def where_clause_cachable?
          where_clause.send(:predicates).map(&:present?).size == @second_level_cache_where_values_hash.size &&
            @second_level_cache_where_values_hash.none? { |k, v| v.is_a?(Array) }
        end

      # def order_values_cachable?
      #   return true if order_values.empty?
      #   return false unless order_values.one?
      #   return true if order_values.first.in?(klass.column_names)
      #   # return true if order_values.first.try(:expr).in?(klass.column_names)
      #   order_values.first.try(:expr).try(:name).in?(klass.column_names)
      # end

      # def limit_value_cachable?
      #   limit_value.to_i.in?(0..1)
      # end
    end
  end
end
