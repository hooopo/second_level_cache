class SecondLevelCache::ActiveRecord::Railtie < Rails::Railtie
  initializer "second_level_cache.active_record.initialization" do
    ActiveRecord::Base.send(:include, SecondLevelCache::Mixin)
    ActiveRecord::Base.send(:include, SecondLevelCache::ActiveRecord::Base)
    ActiveRecord::Base.send(:extend, SecondLevelCache::ActiveRecord::FetchByUniqKey)
    ActiveRecord::Base.send(:extend, SecondLevelCache::ActiveRecord::MultiReadFromCache)

    ActiveRecord::Base.send(:include, SecondLevelCache::ActiveRecord::Persistence)
    ActiveRecord::Associations::BelongsToAssociation.send(:include, SecondLevelCache::ActiveRecord::Associations::BelongsToAssociation)
    ActiveRecord::Associations::HasOneAssociation.send(:include, SecondLevelCache::ActiveRecord::Associations::HasOneAssociation)
    ActiveRecord::Associations::Preloader::BelongsTo.send(:include, SecondLevelCache::ActiveRecord::Associations::Preloader::BelongsTo)
  end
end
