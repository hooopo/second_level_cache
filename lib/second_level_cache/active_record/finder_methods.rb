# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module FinderMethods
      # TODO: find_some
      # http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_one
      #
      # Cacheable:
      #
      #     current_user.articles.where(status: 1).visiable.find(params[:id])
      #
      # Uncacheable:
      #
      #     Article.where("user_id = '1'").find(params[:id])
      #     Article.where("user_id > 1").find(params[:id])
      #     Article.where("articles.user_id = 1").find(prams[:id])
      #     Article.where("user_id = 1 AND ...").find(params[:id])
      def find_one(id)
        return super unless cachable?

        id = id.id if ActiveRecord::Base == id
        record = @klass.read_second_level_cache(id)
        return record if record && where_values_match_cache?(record)

        record = super
        record.write_second_level_cache
        record
      end

      # http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first
      #
      # Cacheable:
      #
      #     User.where(id: 1).first
      #     User.where(id: 1).last
      #
      # Uncacheable:
      #
      #     User.where(name: 'foo').first
      #     User.where(age: 18).first
      #
      def first(limit = nil)
        return super if limit.to_i > 1
        return super unless cachable?
        # only have primary_key condition in where
        if where_values_hash.length == 1 && where_values_hash.key?(primary_key)
          record = @klass.read_second_level_cache(where_values_hash[primary_key])
          return record if record
        end

        record = super
        record&.write_second_level_cache
        record
      end

      private

      # readonly_value - active_record/relation/query_methods.rb Rails 5.1 true/false
      def cachable?
        second_level_cache_enabled? &&
          limit_one? &&
          !eager_loading? &&
          select_values.blank? &&
          order_values_can_cache? &&
          readonly_value.blank? &&
          joins_values.blank? &&
          !@klass.locking_enabled? &&
          where_clause_predicates_all_equality?
      end

      def order_values_can_cache?
        return true if order_values.empty?
        return false unless order_values.one?
        return true if order_values.first == klass.primary_key
        return false unless order_values.first.is_a?(::Arel::Nodes::Ordering)
        return true if order_values.first.expr == klass.primary_key
        order_values.first.expr.try(:name) == klass.primary_key
      end

      def where_clause_predicates_all_equality?
        where_clause.send(:predicates).size == where_values_hash.size
      end

      def where_values_match_cache?(record)
        where_values_hash.all? do |key, value|
          if value.is_a?(Array)
            value.include?(record.read_attribute(key))
          else
            record.read_attribute(key) == value
          end
        end
      end

      def limit_one?
        limit_value.blank? || limit_value == 1
      end
    end
  end
end
