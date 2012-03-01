require 'second_level_cache/active_record/base'
require 'second_level_cache/active_record/finder_methods'
require 'second_level_cache/active_record/persistence'
require 'second_level_cache/active_record/singular_association'

ActiveRecord::Base.send(:include, SecondLevelCache::Mixin)
ActiveRecord::Base.send(:include, SecondLevelCache::ActiveRecord::Base)
ActiveRecord::FinderMethods.send(:include, SecondLevelCache::ActiveRecord::FinderMethods)
ActiveRecord::Persistence.send(:include, SecondLevelCache::ActiveRecord::Persistence)
ActiveRecord::Associations::SingularAssociation.send(:include, SecondLevelCache::ActiveRecord::Associations::SingularAssociation)
