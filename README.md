## 简介

SecondLevelCache is a write-through and read-through caching library inspired by Cache Money and cache_fu, support only Rails3 and ActiveRecord.

Read-Through: Queries by ID, like current_user.articles.find(params[:id]), will first look in cache store and then look in the database for the results of that query. If there is a cache miss, it will populate the cache.

Write-Through: As objects are created, updated, and deleted, all of the caches are automatically kept up-to-date and coherent.

## 使用
初始化redis：

``````ruby
# config/initializers/redis.rb
$redis = Redis.new
``````
在model里设置是否使用缓存:

``````ruby
class User < ActiveRecord::Base
  acts_as_cached(:ttl => 3.day)
end
``````
## 支持查询

* User.find(1)
* User.find_by_id(1), User.find_by_id!(1), User.find_by_id_and_name(1, "Hooopo"), User.where(:status => 1).find_by_id(1), user.articles.find_by_id(1)
* user.articles.find(1), user.where(:status => 1).find(1), user.where("status = 1").find(1)
* article.user

## 原理

每个查询之前，先判断该查询是否满足可缓存的条件：

 * 是否为主键查询，比如：User.find(1)
 * 没有join、lock、group、动态函数(sum/count/max等)
 * 是否为简单的条件查询(不含有in、between、>、<、!=、is等)。比如: User.where(:status => 1).where("level = 2").find(1)

如果满足以上条件，则先从缓存中读取记录，如果缓存中不存在记录，再到数据库中获取记录，并将得到的记录更新到缓存里。

在 after_commit, :on => :create/:update/:destroy 对记录的创建、更新、删除做监控。保证缓存内记录与数据库一致。
