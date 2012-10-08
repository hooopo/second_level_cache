# SecondLevelCache

SecondLevelCache is a write-through and read-through caching library inspired by Cache Money and cache_fu, support only Rails3 and ActiveRecord.

Read-Through: Queries by ID, like `current_user.articles.find(params[:id])`, will first look in cache store and then look in the database for the results of that query. If there is a cache miss, it will populate the cache.

Write-Through: As objects are created, updated, and deleted, all of the caches are automatically kept up-to-date and coherent.

## Risk

SecondLevelCache is not fully test and verify in production enviroment right now. Use it at your own risk.

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

## configure

cache_store: Default is Rails.cache  
logger: Default is Rails.logger  
cache_key_prefix: Avoid cache key conflict with other application, Default is 'slc'  

You can config like this:

```ruby
# config/initializers/second_level_cache.rb
SecondLevelCache.configure do |config|
  config.cache_store = ActiveSupport::Cache::MemoryStore.new
  config.logger = Logger.new($stdout)
  config.cache_key_prefix = 'domain'
end
```
