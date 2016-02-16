# SecondLevelCache

[![Gem Version](https://badge.fury.io/rb/second_level_cache.svg)](http://badge.fury.io/rb/second_level_cache)
[![Dependency Status](https://gemnasium.com/hooopo/second_level_cache.svg)](https://gemnasium.com/hooopo/second_level_cache)
[![Build Status](https://travis-ci.org/hooopo/second_level_cache.svg?branch=master)](https://travis-ci.org/hooopo/second_level_cache)
[![Code Climate](https://codeclimate.com/github/hooopo/second_level_cache.svg)](https://codeclimate.com/github/hooopo/second_level_cache)

SecondLevelCache is a write-through and read-through caching library inspired by Cache Money and cache_fu, support ActiveRecord 4.

Read-Through: Queries by ID, like `current_user.articles.find(params[:id])`, will first look in cache store and then look in the database for the results of that query. If there is a cache miss, it will populate the cache.

Write-Through: As objects are created, updated, and deleted, all of the caches are automatically kept up-to-date and coherent.


## Install

In your gem file:

```ruby
gem "second_level_cache", "~> 2.1.9"
```

For ActiveRecord 3:

```ruby
gem "second_level_cache", "~> 1.6"
```

## Usage

For example, cache User objects:

```ruby
class User < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.week)
end
```

Then it will fetch cached object in this situations:

```ruby
User.find(1)
user.articles.find(1)
User.where(:status => 1).find(1)
article.user
```

Cache key:

```ruby
user = User.find 1
user.second_level_cache_key  # We will get the key looks like "slc/user/1/0"
```

Expires cache:

```ruby
user = User.find(1)
user.expire_second_level_cache
```
or expires cache using class method:
```ruby
User.expire_second_level_cache(1)
```

Disable SecondLevelCache:

```ruby
User.without_second_level_cache do
  user = User.find 1
  # ...
end
```

Only `SELECT *` query will be cached:

```ruby
# this query will NOT be cached
User.select("id, name").find(1)
```

## Notice

* SecondLevelCache cache by model name and id, so only find_one query will work.
* Only equal conditions query WILL get cache; and SQL string query like `User.where("name = 'Hooopo'").find(1)` WILL NOT work.
* SecondLevelCache sync cache after transaction commit:

```ruby
# user and account's write_second_level_cache operation will invoke after the logger.
ActiveRecord::Base.transaction do
   user.save
   account.save
   Rails.logger.info "info"
end # <- Cache write

# if you want to do something after user and account's write_second_level_cache operation, do this way:
ActiveRecord::Base.transaction do
   user.save
   account.save
end # <- Cache write
Rails.logger.info "info"
```

* If you are using SecondLevelCache with database_cleaner, you should set cleaning strategy to `:truncation`:

```ruby
DatabaseCleaner.strategy = :truncation
```

## Configure

In production env, we recommend to use [Dalli](https://github.com/mperham/dalli) as Rails cache store.
```ruby
 config.cache_store = [:dalli_store, APP_CONFIG["memcached_host"], {:namespace => "ns", :compress => true}]
```

## Tips:

* When you want to clear only second level cache apart from other cache for example fragment cache in cache store,
you can only change the `cache_key_prefix`:

```ruby
SecondLevelCache.configure.cache_key_prefix = "slc1"
```
* When schema of your model changed, just change the `version` of the speical model, avoding clear all the cache.

```ruby
class User < ActiveRecord::Base
  acts_as_cached(:version => 2, :expires_in => 1.week)
end
```

* It provides a great feature, not hits db when fetching record via unique key(not primary key).

```ruby
# this will fetch from cache
user = User.fetch_by_uniq_keys(nick_name: "hooopo")
post = Post.fetch_by_uniq_keys(user_id: 2, slug: "foo")

# this also fetch from cache
user = User.fetch_by_uniq_keys!(nick_name: "hooopo") # this will raise `ActiveRecord::RecordNotFound` Exception when nick name not exists.
```

* You can use Rails's [Eager Loading](http://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations) feature as normal. Even better, second_level_cache will transform the `IN` query into a Rails.cache.multi_read operation. For example:

```ruby
Answer.includes(:question).limit(10).order("id DESC").each{|answer| answer.question.title}
Answer Load (0.2ms)  SELECT `answers`.* FROM `answers` ORDER BY id DESC LIMIT 10 # Only one SQL query and one Rails.cache.read_multi fetching operation.
```
[Details for read_multi feature](http://hooopo.writings.io/articles/a9cae5e0).

## Contributors

* [chloerei](https://github.com/chloerei)
* [reyesyang](https://github.com/reyesyang)
* [hooopo](https://github.com/hooopo)
* [sishen](https://github.com/sishen)

## License

MIT License
