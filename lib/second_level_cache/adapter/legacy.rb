# frozen_string_literal: true

module SecondLevelCache
  module Adapter
    module Legacy
      module SecondLevelCache
        extend ActiveSupport::Concern
        module ClassMethods
          delegate :logger, to: ::SecondLevelCache::Config
        end
      end
      ::SecondLevelCache.send(:include, ::SecondLevelCache::Adapter::Legacy::SecondLevelCache)

      module Config
        extend ActiveSupport::Concern
        module ClassMethods
          attr_writer :logger

          def logger
            ActiveSupport::Deprecation.warn("logger is deprecated and will be removed from SecondLevelCache 2.7.0")
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
