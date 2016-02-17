# -*- encoding : utf-8 -*-
require 'second_level_cache/active_record/base'
require 'second_level_cache/active_record/core'
require 'second_level_cache/active_record/fetch_by_uniq_key'
require 'second_level_cache/active_record/finder_methods'
require 'second_level_cache/active_record/persistence'
require 'second_level_cache/active_record/belongs_to_association'
require 'second_level_cache/active_record/has_one_association'
require 'second_level_cache/active_record/preloader'

if defined? Rails
  require 'second_level_cache/active_record/railtie'
else
  ActiveRecord::Base.send(:include, SecondLevelCache::Mixin)
  ActiveRecord::Base.send(:prepend, SecondLevelCache::ActiveRecord::Base)
  ActiveRecord::Base.send(:extend, SecondLevelCache::ActiveRecord::FetchByUniqKey)

  ActiveRecord::Base.send(:prepend, SecondLevelCache::ActiveRecord::Persistence)
  ActiveRecord::Associations::BelongsToAssociation.send(:prepend, SecondLevelCache::ActiveRecord::Associations::BelongsToAssociation)
  ActiveRecord::Associations::HasOneAssociation.send(:prepend, SecondLevelCache::ActiveRecord::Associations::HasOneAssociation)
  ActiveRecord::Associations::Preloader::BelongsTo.send(:prepend, SecondLevelCache::ActiveRecord::Associations::Preloader::BelongsTo)
end
