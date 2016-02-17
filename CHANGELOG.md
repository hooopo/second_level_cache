2.2.0
-----

* ActiveRecord 5 ready! Do not support ActiveRecord 4 and lower versions now (use second_level_cache 2.1.x).
* Requirement Ruby 2.3+.

2.0.0.rc1
-----
* ActiveRecord 4 ready!
* read multi support for preloading. `Article.includes(:user).limit(5).to_a` will fetch all articles' users from cache preferentially.
* remove dependency warning
* remove support for find_by_xx which will be removed in Rails 4.1

1.6.2
-----
* [can disable/enable fetch_by_uinq_key method]
* [Fix Bug: serialized attribute columns marshal issue #11]

1.6.1
-----
* [Fix bug: undefined method `select_all_column?' for []:ActiveRecord::Relation] by sishen

1.6.0
-----
* [write through cache]
* [disable SecondLevelCache for spicial model]
* [only cache `SELECT *` query]

1.5.1
-----
* [use new marshal machanism to avoid clear assocation cache manually]

1.5.0
-----
* [add cache version to quick clear cache for special model]

1.4.1
-----
* [fix errors when belongs_to association return nil]

1.4.0
-----
* [cache has one assciation]

1.3.2
-----
* [fix has one assciation issue]

1.3.1
-----
* [clean cache after update_column/increment!/decrement!]

1.3.0
-----
* [clean cache after touch]

1.2.1
-----
* [fix polymorphic association bug]

1.2.0
-----
* [clear cache after update_counters](https://github.com/csdn-dev/second_level_cache/commit/240dde81199124092e0e8ad0500c167ac146e301)





