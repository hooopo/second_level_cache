# frozen_string_literal: true

require "second_level_cache/mixin"
require "second_level_cache/active_record/base"
require "second_level_cache/active_record/core"
require "second_level_cache/active_record/query_cache"
require "second_level_cache/active_record/persistence"
require "second_level_cache/active_record/has_one_association"
require "second_level_cache/active_record/has_one_through_association"

# http://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html
# ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)
ActiveSupport.on_load(:active_record, run_once: true) do
  if (Bundler.definition.gem("paranoia") rescue false)
    require "second_level_cache/adapter/paranoia"
    include SecondLevelCache::Adapter::Paranoia::ActiveRecord
    SecondLevelCache::Mixin.send(:prepend, SecondLevelCache::Adapter::Paranoia::Mixin)
  end

  include SecondLevelCache::Mixin
  prepend SecondLevelCache::ActiveRecord::Base
  include SecondLevelCache::ActiveRecord::Persistence

  ActiveRecord::Associations::HasOneAssociation.send(:include, SecondLevelCache::ActiveRecord::Associations::HasOneAssociation)
  ActiveRecord::Associations::HasOneThroughAssociation.send(:include, SecondLevelCache::ActiveRecord::Associations::HasOneThroughAssociation)
  ActiveRecord::Relation.send(:prepend, SecondLevelCache::ActiveRecord::QueryCache)
end
