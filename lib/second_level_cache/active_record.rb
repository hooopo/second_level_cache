# frozen_string_literal: true

require "second_level_cache/mixin"
require "second_level_cache/active_record/base"
require "second_level_cache/active_record/core"
require "second_level_cache/active_record/fetch_by_uniq_key"
require "second_level_cache/active_record/finder_methods"
require "second_level_cache/active_record/persistence"
require "second_level_cache/active_record/belongs_to_association"
require "second_level_cache/active_record/has_one_association"
require "second_level_cache/active_record/preloader/association"
require "second_level_cache/active_record/preloader/legacy"

# http://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html
# ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)
ActiveSupport.on_load(:active_record, run_once: true) do
  if Bundler.definition.dependencies.find { |x| x.name == "paranoia" }
    require "second_level_cache/adapter/paranoia"
    include SecondLevelCache::Adapter::Paranoia::ActiveRecord
    SecondLevelCache::Mixin.send(:prepend, SecondLevelCache::Adapter::Paranoia::Mixin)
  end

  include SecondLevelCache::Mixin
  prepend SecondLevelCache::ActiveRecord::Base
  extend SecondLevelCache::ActiveRecord::FetchByUniqKey
  prepend SecondLevelCache::ActiveRecord::Persistence

  ActiveRecord::Associations::BelongsToAssociation.send(:prepend, SecondLevelCache::ActiveRecord::Associations::BelongsToAssociation)
  ActiveRecord::Associations::HasOneAssociation.send(:prepend, SecondLevelCache::ActiveRecord::Associations::HasOneAssociation)
  ActiveRecord::Relation.send(:prepend, SecondLevelCache::ActiveRecord::FinderMethods)

  # https://github.com/rails/rails/blob/6-0-stable/activerecord/lib/active_record/associations/preloader/association.rb#L117
  if ::ActiveRecord.version < ::Gem::Version.new("7")
    ActiveRecord::Associations::Preloader::Association.send(:prepend, SecondLevelCache::ActiveRecord::Associations::Preloader::Association::Legacy)
  end

  if ::ActiveRecord.version >= ::Gem::Version.new("7")
    # https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/associations/preloader/association.rb#L25
    ActiveRecord::Associations::Preloader::Association.send(:prepend, SecondLevelCache::ActiveRecord::Associations::Preloader::Association)
    ActiveRecord::Associations::Preloader::Association::LoaderQuery.send(:prepend, SecondLevelCache::ActiveRecord::Associations::Preloader::Association::LoaderQuery)
  end
end
