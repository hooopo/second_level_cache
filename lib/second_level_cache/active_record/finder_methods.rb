module SecondLevelCache
  module ActiveRecord
    module FinderMethods
      # TODO: find_some
      # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/relation/finder_methods.rb#L289-L309
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
        return super(id) unless second_level_cache_enabled?
        return super(id) unless select_all_column?

        id = id.id if ActiveRecord::Base == id

        if cachable?
          record = @klass.read_second_level_cache(id)
          if record
            if where_values_hash.blank? || where_values_match_cache?(record)
              return record
            end
          end
        end

        record = super(id)
        record.write_second_level_cache
        record
      end

      private

      def cachable?
        limit_one? &&
          order_values.blank? &&
          includes_values.blank? &&
          preload_values.blank? &&
          readonly_value.nil? &&
          joins_values.blank? &&
          !@klass.locking_enabled? &&
          where_clause_match_equality?
      end

      def where_clause_match_equality?
        where_values_hash.all?
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

      def select_all_column?
        select_values.blank?
      end
    end
  end
end
