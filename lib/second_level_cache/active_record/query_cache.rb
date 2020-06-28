# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module QueryCache
      extend ActiveSupport::Concern

      delegate :cache_store, to: :SecondLevelCache
      delegate :second_level_cache_options, :second_level_cache_cast_for_where_values_hash,
               :second_level_cache_key, :verify_second_level_cache?, :_read_second_level_cache,
               to: :klass

      def initialize(*args, &block)
        @second_level_cache_values = {}
        super
      end

      private
        def exec_queries(&block)
          return super unless exec_queries_cachable?

          key = @second_level_cache_values[:key]
          where_values_hash = @second_level_cache_values[:where_values_hash]
          hit_where_values_hash = @second_level_cache_values[:hit_where_values_hash]

          if key
            missed = []
            keys_hash = hit_where_values_hash[key].each_with_object({}) { |v, h| h[second_level_cache_key(hit_where_values_hash.merge({ key => v }))] = v }
            cache_entities = cache_store.fetch_multi(*keys_hash.keys) { |k| missed << keys_hash[k] and nil }.compact
            if key != primary_key
              second_hash = {}
              cache_entities.each { |k, v| second_hash[second_level_cache_key({ primary_key => v })] = keys_hash[k] }
              cache_entities = cache_store.read_multi(*second_hash.keys) { |k| missed << second_hash[k] and nil }.compact
            end
            hitted_records = RecordMarshal.load_multi(cache_entities.values, &block)
            hitted_records.delete_if { |r| missed << r.read_attribute(key) unless verify_second_level_cache?(r, where_values_hash) }
            if missed.present?
              missed_records = klass.find_by_sql(rewhere({ key => missed }).arel, &block).tap { |rs| rs.each(&:write_second_level_cache) }
              @records = (hitted_records | missed_records).freeze
            else
              @records = hitted_records.freeze
            end
          else
            @records = [_read_second_level_cache(hit_where_values_hash, where_values_hash, &block)].compact.freeze
            return super.tap { |rs| rs.each(&:write_second_level_cache) } if @records.empty?
          end

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
            where_clause_cachable? &&
            limit_value_cachable? &&
            order_values_cachable?
        end

        def where_clause_cachable?
          @second_level_cache_values[:where_values_hash] = where_values_hash = second_level_cache_cast_for_where_values_hash(self.send(:where_values_hash))
          return false if where_clause.send(:predicates).map(&:present?).size != where_values_hash.size
          return false if where_values_hash.count { |_, v| v.is_a?(Array) } > 1
          second_level_cache_options[:unique_indexes].any? do |indexes|
            if  indexes.all? do |index|
                  if !where_values_hash.has_key?(index)
                    @second_level_cache_values.delete(:key)
                    break
                  elsif where_values_hash[index].is_a?(Array)
                    @second_level_cache_values[:key] = index
                  end
                  true
                end
              @second_level_cache_values[:hit_where_values_hash] = where_values_hash.slice(*indexes)
            end
          end
        end

        def limit_value_cachable?
          !@second_level_cache_values.has_key?(:key) || limit_value.nil?
        end

        # TODO: Implement select values cache
        def select_values_cachable?
          select_values.empty? # || (select_values.map(&:to_s) - klass.column_names).blank?
        end

        # TODO: Implement single order value sort cache
        def order_values_cachable?
          !@second_level_cache_values.has_key?(:key) || order_values.empty?
          # return false unless order_values.one?
          # return true if order_values.first.in?(klass.column_names)
          # # return true if order_values.first.try(:expr).in?(klass.column_names)
          # order_values.first.try(:expr).try(:name).in?(klass.column_names)
        end
    end
  end
end
