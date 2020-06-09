# frozen_string_literal: true

module SecondLevelCache
  module ActiveRecord
    module FetchByUniqKey
      def fetch_by_uniq_keys(where_values)
        where_values_keys = where_values.keys.map(&:to_s).sort
        second_level_cache_options[:unique_indexes] |= [where_values_keys]
        fetch_by_warning(:fetch_by_uniq_keys, :find_by, where_values_keys)
        find_by(where_values)
      end

      def fetch_by_uniq_keys!(where_values)
        where_values_keys = where_values.keys.map(&:to_s).sort
        second_level_cache_options[:unique_indexes] |= [where_values_keys]
        fetch_by_warning(:fetch_by_uniq_keys!, :find_by!, where_values_keys)
        find_by!(where_values)
      end

      def fetch_by_uniq_key(value, uniq_key_name)
        second_level_cache_options[:unique_indexes] |= [[uniq_key_name]]
        fetch_by_warning(:fetch_by_uniq_key, :find_by, uniq_key_name)
        find_by(uniq_key_name => value)
      end

      def fetch_by_uniq_key!(value, uniq_key_name)
        second_level_cache_options[:unique_indexes] |= [[uniq_key_name]]
        fetch_by_warning(:fetch_by_uniq_key!, :find_by!, uniq_key_name)
        find_by!(uniq_key_name => value)
      end

      private def fetch_by_warning(deprecated_method, instead_method, keys)
        ActiveSupport::Deprecation.warn(
          <<-WARNING.strip_heredoc
            #{deprecated_method} is deprecated and will be removed from SecondLevelCache 3 !
            You should to make #{keys} append to unique_indexes option value pass to second_level_cache method.
            After that you can use #{instead_method} instead of #{deprecated_method}, it will also read cache first.
          WARNING
        )
      end
    end
  end
end
