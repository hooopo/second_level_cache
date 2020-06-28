# frozen_string_literal: true

module SecondLevelCache
  module Adapter
    module Legacy
      module SecondLevelCache
        extend ActiveSupport::Concern
        module ClassMethods
          delegate :logger, to: ::SecondLevelCache::Config

          def without_second_level_cache
            ActiveSupport::Deprecation.warn("without_second_level_cache is deprecated and will be removed in the future!")
            old_cache_enabled = ::SecondLevelCache.cache_enabled?
            ::SecondLevelCache.cache_enabled = false

            yield
          ensure
            ::SecondLevelCache.cache_enabled = old_cache_enabled
          end

          def cache_enabled?
            ActiveSupport::Deprecation.warn("cache_enabled? is deprecated and will be removed in the future!")
            cache_enabled = Thread.current[:slc_cache_enabled]
            cache_enabled.nil? ? true : cache_enabled
          end

          def cache_enabled=(cache_enabled)
            ActiveSupport::Deprecation.warn("cache_enabled= is deprecated and will be removed in the future!")
            Thread.current[:slc_cache_enabled] = cache_enabled
          end
        end
      end
      ::SecondLevelCache.send(:include, ::SecondLevelCache::Adapter::Legacy::SecondLevelCache)

      module Config
        extend ActiveSupport::Concern
        module ClassMethods
          attr_writer :logger

          def logger
            ActiveSupport::Deprecation.warn("logger is deprecated and will be removed in the future!")
            @logger ||= Rails.logger if defined?(Rails)
            @logger ||= Logger.new(STDOUT)
          end
        end
      end
      ::SecondLevelCache::Config.send(:include, ::SecondLevelCache::Adapter::Legacy::Config)

      module FetchByUniqKey
        extend ActiveSupport::Concern
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
          second_level_cache_options[:unique_indexes] |= [[uniq_key_name.to_s]]
          fetch_by_warning(:fetch_by_uniq_key, :find_by, uniq_key_name)
          find_by(uniq_key_name => value)
        end

        def fetch_by_uniq_key!(value, uniq_key_name)
          second_level_cache_options[:unique_indexes] |= [[uniq_key_name.to_s]]
          fetch_by_warning(:fetch_by_uniq_key!, :find_by!, uniq_key_name)
          find_by!(uniq_key_name => value)
        end

        private def fetch_by_warning(deprecated_method, instead_method, keys)
          ActiveSupport::Deprecation.warn(
            <<-WARNING.strip_heredoc
              #{deprecated_method} is deprecated and will be removed in the future!
              You should to make <#{keys}> append to unique_indexes option value pass to second_level_cache method.
              After that you can use #{instead_method} instead of #{deprecated_method}, it will also read cache first.
            WARNING
          )
        end
      end
      ::ActiveRecord::Base.send(:extend, ::SecondLevelCache::Adapter::Legacy::FetchByUniqKey)

      module Mixin
        extend ActiveSupport::Concern
        module ClassMethods
          delegate :logger, to: ::SecondLevelCache

          def second_level_cache_enabled?
            super && ::SecondLevelCache.cache_enabled?
          end

          def without_second_level_cache(&blk)
            ActiveSupport::Deprecation.warn(
              <<-WARNING.strip_heredoc
                without_second_level_cache is deprecated and will be removed in the future!
                You should call skip_query_cache, it can skip second_level_cache and ActiveRecord::QueryCache at the same time.
                For more details, please see https://github.com/rails/rails/blob/v6.0.3.2/activerecord/lib/active_record/relation/query_methods.rb#L984
              WARNING
            )
            ::SecondLevelCache.without_second_level_cache(&blk) if blk
          end

          def second_level_cache_key(id)
            return super if id.is_a?(Hash)
            ActiveSupport::Deprecation.warn("argument should be a hash object, id type argument will not support in the future!")
            super({ primary_key => id })
          end

          def read_second_level_cache(id, &block)
            return super if id.is_a?(Hash)
            ActiveSupport::Deprecation.warn("argument should be a hash object, id type argument will not support in the future!")
            super({ primary_key => id }, &block)
          end

          def expire_second_level_cache(id)
            return super if id.is_a?(Hash)
            ActiveSupport::Deprecation.warn("argument should be a hash object, id type argument will not support in the future!")
            super({ primary_key => id })
          end
        end

        def second_level_cache_key(*indexes)
          return super unless indexes.empty?
          ActiveSupport::Deprecation.warn("argument should exists, no argument call will not support in the future!")
          super(@primary_key)
        end
      end
      ::ActiveRecord::Base.send(:include, ::SecondLevelCache::Adapter::Legacy::Mixin)
    end
  end
end
