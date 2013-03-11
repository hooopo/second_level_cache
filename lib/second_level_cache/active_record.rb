# -*- encoding : utf-8 -*-
require 'second_level_cache/active_record/base'
require 'second_level_cache/active_record/fetch_by_uniq_key'
require 'second_level_cache/active_record/finder_methods'
require 'second_level_cache/active_record/persistence'
require 'second_level_cache/active_record/belongs_to_association'
require 'second_level_cache/active_record/has_one_association'

ActiveRecord::Base.send(:include, SecondLevelCache::Mixin)
ActiveRecord::Base.send(:include, SecondLevelCache::ActiveRecord::Base)
ActiveRecord::Base.send(:extend, SecondLevelCache::ActiveRecord::FetchByUniqKey)
ActiveRecord::Relation.send(:include, SecondLevelCache::ActiveRecord::FinderMethods)
ActiveRecord::Base.send(:include, SecondLevelCache::ActiveRecord::Persistence)
ActiveRecord::Associations::BelongsToAssociation.send(:include, SecondLevelCache::ActiveRecord::Associations::BelongsToAssociation)
ActiveRecord::Associations::HasOneAssociation.send(:include, SecondLevelCache::ActiveRecord::Associations::HasOneAssociation)
