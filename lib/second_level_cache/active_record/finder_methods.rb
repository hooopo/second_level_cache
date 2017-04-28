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
        return super(limit) if limit.to_i > 1
        # only have primary_key condition in where
        if where_values_hash.length == 1 && where_values_hash.key?(primary_key)
          record = @klass.read_second_level_cache(where_values_hash[primary_key])
          return record if record
        end

        record = super(limit)
        record.write_second_level_cache if record
        record
      end

      private

      # readonly_value - active_record/relation/query_methods.rb Rails 5.1 true/false
      def cachable?
        limit_one? &&
          order_values.blank? &&
          includes_values.blank? &&
          preload_values.blank? &&
          readonly_value.blank? &&
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
