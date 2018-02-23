2.4.0
---------

- Fix for support Rails 5.2;
- Now second_level_cache 2.4.x has required Rails > 5.2;
- Enable `frozen_string_literal = true`;

2.3.1
-------

- Fix some cases will raise "uninitialized constant SecondLevelCache::Mixin" error. (#66)

2.3.0
-------

* Use Model schema digest as cache_version, so you don't need set `:version` option now. (#60)
* Fix `store` serialize option (#62)
* Remove `acts_as_cached` method now! Please use `second_level_cache`. (#59)

2.2.7
-------

* Use `second_level_cache` instead of `acts_as_cached` method to setup in model. (#56)

2.2.6
-------

* Fix warning in Ruby 2.4.0. (#54)

2.2.5
-------

* Flush cache when belongs_to keys are changed; (#51)
* Fix #52 in ActiveRecord 5.0.1, `records_for` API has changed, it's want an `ActiveRecord::Relation` instance to include a `load` method, but second_level_cached returned an Array. (#53)
* Fix Rails 5.0.1 `@second_level_cache_enabled` not define warning.

2.2.4
-------

* Fix update conflict in same thread or request context for Cache object. (#49)

2.2.3
-------

* Fix issue with Rails enums. (#43)
* Fix to update cache on `update_columns`, `update_attribute`. (#43)

2.2.2
-------

* Add `where(id: n).first`, `where(id: n).last` hit cache support. This improve will avoid some gems query database, for example: [devise](https://github.com/plataformatec/devise) `current_user` method.

2.2.1
-------

* ActiveRecord 5 ready! Do not support ActiveRecord 4 and lower versions now (use second_level_cache 2.1.x).
* Requirement Ruby 2.3+.

2.0.0
-------

* ActiveRecord 4 ready!
* read multi support for preloading. `Article.includes(:user).limit(5).to_a` will fetch all articles' users from cache preferentially.
* remove dependency warning
* remove support for find_by_xx which will be removed in Rails 4.1

1.6.2
-------

* [can disable/enable fetch_by_uinq_key method]
* [Fix Bug: serialized attribute columns marshal issue #11]

1.6.1
-------

* [Fix bug: undefined method `select_all_column?' for []:ActiveRecord::Relation] by sishen

1.6.0
-------

* [write through cache]
* [disable SecondLevelCache for spicial model]
* [only cache `SELECT *` query]

1.5.1
-------

* [use new marshal machanism to avoid clear assocation cache manually]

1.5.0
-------

* [add cache version to quick clear cache for special model]

1.4.1
-------

* [fix errors when belongs_to association return nil]

1.4.0
-------

* [cache has one assciation]

1.3.2
-------

* [fix has one assciation issue]

1.3.1
-------

* [clean cache after update_column/increment!/decrement!]

1.3.0
-------

* [clean cache after touch]

1.2.1
-------

* [fix polymorphic association bug]

1.2.0
-------

* [clear cache after update_counters](https://github.com/csdn-dev/second_level_cache/commit/240dde81199124092e0e8ad0500c167ac146e301)





