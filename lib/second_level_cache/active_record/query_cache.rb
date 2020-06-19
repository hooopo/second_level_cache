# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module QueryCache
      extend ActiveSupport::Concern

      def initialize(*args, &block)
        @second_level_cache = {}
        super
      end

      private
        def exec_queries(&block)
          return super unless exec_queries_cachable?

          record = klass.read_second_level_cache(second_level_cache_id, &block)
          if record && where_values_match_cache?(record)
            @records = [record].freeze
            preload_associations(@records) unless skip_preloading_value
            @records.each(&:readonly!) if readonly_value
            @loaded = true
            @records
          else
            super.tap { |records| write_second_level_cache(records) }
          end
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
          where_values_hash = self.send(:where_values_hash)
          return false if where_clause.send(:predicates).map(&:present?).size != where_values_hash.size
          return false if where_values_hash.any? { |k, v| v.is_a?(Array) }
          klass.second_level_cache_options[:unique_indexes].any? do |unique_indexes|
            if unique_indexes.all? { |index| where_values_hash.has_key?(index) }
              @second_level_cache[:unique_indexes] = unique_indexes
            end
          end
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

        def second_level_cache_id
          where_values_hash = self.send(:where_values_hash)
          return where_values_hash[primary_key] if where_values_hash.has_key?(primary_key)

          uniq_key = where_values_hash.slice(*@second_level_cache[:unique_indexes]).map do |k, v|
            v = Digest::MD5.hexdigest(v) if v.respond_to?(:size) && v.size >= 32
            "#{k}=#{v}"
          end.sort.join("&")
          @second_level_cache[:uniq_key] = klass.second_level_cache_key(uniq_key)
          SecondLevelCache.cache_store.read(@second_level_cache[:uniq_key])
        end

        def where_values_match_cache?(record)
          where_values_hash.all? { |k, v| record.read_attribute(k) == klass.type_for_attribute(k).cast(v) }
        end

        def write_second_level_cache(records)
          return records.first.write_second_level_cache(@second_level_cache[:uniq_key]) if records.present?
          SecondLevelCache.cache_store.delete(@second_level_cache[:uniq_key]) if @second_level_cache.has_key?(:uniq_key)
        end
    end
  end
end
