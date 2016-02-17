module SecondLevelCache
  module ActiveRecord
    class Railtie < Rails::Railtie
      initializer 'second_level_cache.active_record.initialization' do
        ActiveRecord::Base.send(:include, SecondLevelCache::Mixin)
        ActiveRecord::Base.send(:prepend, SecondLevelCache::ActiveRecord::Base)
        ActiveRecord::Base.send(:extend, SecondLevelCache::ActiveRecord::FetchByUniqKey)

        ActiveRecord::Base.send(:prepend, SecondLevelCache::ActiveRecord::Persistence)
        ActiveRecord::Associations::BelongsToAssociation.send(:prepend, SecondLevelCache::ActiveRecord::Associations::BelongsToAssociation)
        ActiveRecord::Associations::HasOneAssociation.send(:prepend, SecondLevelCache::ActiveRecord::Associations::HasOneAssociation)
        ActiveRecord::Associations::Preloader::BelongsTo.send(:prepend, SecondLevelCache::ActiveRecord::Associations::Preloader::BelongsTo)
      end
    end
  end
end
