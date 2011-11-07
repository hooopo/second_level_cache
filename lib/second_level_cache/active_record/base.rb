# encoding: utf-8
module SecondLevelCache
  module ActiveRecord
    module Base
      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods)
      end

      module ClassMethods
        def second_level_cache_init
          # NOTICE after_commit twice would override the first bug!
          # https://github.com/rails/rails/issues/988
          after_commit :expire_second_level_cache, :on => :destroy
          after_commit :update_second_level_cache, :on => :update
          after_commit :create_second_level_cache, :on => :create
        end
      end

      module InstanceMethods
        def expire_second_level_cache
          self.class.cache_store.delete(second_level_cache_key) if self.class.second_level_cache_enabled?
          true
        end

        # 记录更改时不直接删除缓存，而是更新缓存
        def update_second_level_cache
          self.class.cache_store.set(second_level_cache_key, self) if self.class.second_level_cache_enabled?
          true
        end

        # Write Throuht
        def create_second_level_cache
          self.calss.cache_store.set(second_level_cache_key, self) if self.class.second_level_cache_enabled?
          true
        end

        def second_level_cache_key
          "#{cache_name}/#{id}"
        end

        def cache_name
          @cache_name ||= self.class.table_name
        end     
      end
    end
  end
end
