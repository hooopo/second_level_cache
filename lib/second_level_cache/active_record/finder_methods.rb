# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module FinderMethods
      extend ActiveSupport::Concern

      included do
        alias_method_chain :find_one, :second_level_cache
        alias_method_chain :find_some, :second_level_cache
      end

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
          record = @klass.read_second_level_cache(id)
          if record
            return record if where_values.blank? || where_values_match_cache?(record)
          end
        end

        record = find_one_without_second_level_cache(id)
        record.write_second_level_cache
        record
      end

      def find_some_with_second_level_cache(ids)
        return find_some_without_second_level_cache(id) unless second_level_cache_enabled?
        return find_some_without_second_level_cache(id) unless select_all_column?

        if cachable?
          result = multi_read_from_cache(ids)
        else
          result = where(:id => ids).all
        end

        expected_size =
          if limit_value && ids.size > limit_value
            limit_value
          else
            ids.size
          end

        # 11 ids with limit 3, offset 9 should give 2 results.
        if offset_value && (ids.size - offset_value < expected_size)
          expected_size = ids.size - offset_value
        end

        if result.size == expected_size
          result
        else
          raise_record_not_found_exception!(ids, result.size, expected_size)
        end
      end


      def multi_read_from_cache(ids)
        map_cache_keys = ids.map{|id| klass.second_level_cache_key(id)}
        records_from_cache = ::SecondLevelCache.cache_store.read_multi(*map_cache_keys)
        hitted_ids = records_from_cache.map{|key, _| key.split("/")[2].to_i}
        missed_ids = ids.map{|x| x.to_i} - hitted_ids

        ::SecondLevelCache::Config.logger.info "missed ids -> #{missed_ids.inspect} | hitted ids -> #{hitted_ids.inspect}"

        if missed_ids.empty?
          RecordMarshal.load_multi(records_from_cache.values)
        else
          records_from_db = where(:id => missed_ids)
          records_from_db.map{|record| record.write_second_level_cache ; record} + RecordMarshal.load_multi(records_from_cache.values)
        end
      end

    private

      def cachable?
        limit_one? && order_values.blank? &&
          includes_values.blank? && preload_values.blank? &&
          readonly_value.nil? && joins_values.blank? && !@klass.locking_enabled? &&
          where_values.all? { |where_value| where_value.is_a?(::Arel::Nodes::Equality) }
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
