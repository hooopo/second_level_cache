# SecondLevelCache

[![Gem Version](https://badge.fury.io/rb/second_level_cache.png)](http://badge.fury.io/rb/second_level_cache)

SecondLevelCache is a write-through and read-through caching library inspired by Cache Money and cache_fu, support only Rails3 and ActiveRecord.

Read-Through: Queries by ID, like `current_user.articles.find(params[:id])`, will first look in cache store and then look in the database for the results of that query. If there is a cache miss, it will populate the cache.

Write-Through: As objects are created, updated, and deleted, all of the caches are automatically kept up-to-date and coherent.


## Install

In your gem file:

```ruby
gem "second_level_cache", "~> 1.5"
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
User.find_by_id(1)
User.find_by_id!(1)
User.find_by_id_and_name(1, "Hooopo")
User.where(:status => 1).find_by_id(1)
user.articles.find_by_id(1)
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

Notice:

* SecondLevelCache cache by model name and id, so only find_one query will work.
* only equal conditions query WILL get cache; and SQL string query like `User.where("name = 'Hooopo'").find(1)` WILL NOT work.

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
user = User.fetch_by_uniq_key("hooopo", :nick_name)

# this also fetch from cache
user = User.fetch_by_uniq_key!("hooopo", :nick_name) # this will raise `ActiveRecord::RecordNotFound` Exception when nick name not exists.
```


