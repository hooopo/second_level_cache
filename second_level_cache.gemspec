# -*- encoding: utf-8 -*-
require File.expand_path('../lib/second_level_cache/version', __FILE__)
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.authors       = ["wangxz"]
  gem.email         = ["wangxz@csdn.net"]
  gem.description   = %q{Write Through and Read Through caching library inspired by CacheMoney and cache_fu, support only Rails3 and ActiveRecord.}
  gem.summary       = <<-SUMMARY
  SecondLevelCache is a write-through and read-through caching library inspired by Cache Money and cache_fu, support only Rails3 and ActiveRecord.

  Read-Through: Queries by ID, like current_user.articles.find(params[:id]), will first look in cache store and then look in the database for the results of that query. If there is a cache miss, it will populate the cache.

  Write-Through: As objects are created, updated, and deleted, all of the caches are automatically kept up-to-date and coherent.
  SUMMARY

  gem.homepage      = "https://github.com/csdn-dev/second_level_cache"

  gem.files         = Dir.glob("lib/**/*.rb") + [
    "README.md",
    "Rakefile",
    "Gemfile",
    "init.rb",
    "CHANGELOG.md",
    "second_level_cache.gemspec"
  ]
  gem.test_files    = Dir.glob("test/**/*.rb")
  gem.executables   = gem.files.grep(%r{^bin/})
  gem.name          = "second_level_cache"
  gem.require_paths = ["lib"]
  gem.version       = SecondLevelCache::VERSION

  gem.add_runtime_dependency "activesupport", ["~> 3.2.0"]

  gem.add_development_dependency "activerecord", ["~> 3.2.0"]
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rake"
end
