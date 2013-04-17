# -*- encoding : utf-8 -*-
require 'second_level_cache/arel/wheres'

module SecondLevelCache
  module ActiveRecord
    module FinderMethods
      extend ActiveSupport::Concern

      included do
        class_eval do
          alias_method_chain :find_one, :second_level_cache
        end
      end

      # TODO find_some
      # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/relation/finder_methods.rb#L289-L309
      #
      # Cacheable:
      #
      #     current_user.articles.where(:status => 1).visiable.find(params[:id])
      #
      # Uncacheable:
      #
      #     Article.where("user_id = '1'").find(params[:id])
      #     Article.where("user_id > 1").find(params[:id])
      #     Article.where("articles.user_id = 1").find(prams[:id])
      #     Article.where("user_id = 1 AND ...").find(params[:id])
      def find_one_with_second_level_cache(id)
        return find_one_without_second_level_cache(id) unless second_level_cache_enabled?
        return find_one_without_second_level_cache(id) unless select_all_column?
        
        id = id.id if ActiveRecord::Base === id

        if cachable?
          if record = @klass.read_second_level_cache(id)
            return record
          end
        end
       
        if cachable_without_conditions?
          if record = @klass.read_second_level_cache(id)
            return record if where_match_with_cache?(where_values, record)
          end
        end
 
        record = find_one_without_second_level_cache(id)
        record.write_second_level_cache
        record
      end

      private

      def cachable?
        where_values.blank? &&
          limit_one? && order_values.blank? &&
          includes_values.blank? && preload_values.blank? &&
          readonly_value.nil? && joins_values.blank? && !@klass.locking_enabled?
      end

      def cachable_without_conditions?
        limit_one? && order_values.blank? &&
          includes_values.blank? && preload_values.blank? &&
          readonly_value.nil? && joins_values.blank? && !@klass.locking_enabled?
      end

      def where_match_with_cache?(where_values, cache_record)
        condition = SecondLevelCache::Arel::Wheres.new(where_values)
        return false unless condition.all_equality?
        condition.extract_pairs.all? do |pair|
          cache_record.read_attribute(pair[:left]) == pair[:right]
        end
      end

      def limit_one?
        limit_value.blank? || limit_value == 1
      end

      def select_all_column?
        select_values.blank?
      end
    end
  end
end
