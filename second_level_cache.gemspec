# frozen_string_literal: true

require File.expand_path("../lib/second_level_cache/version", __FILE__)
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.authors = ["Hooopo"]
  gem.email = ["hoooopo@gmail.com"]
  gem.description = "Write-through and read-through caching library inspired by CacheMoney and cache_fu, for ActiveRecord 6, 7, and 8."
  gem.summary = <<-SUMMARY
  SecondLevelCache is a write-through and read-through caching library inspired by Cache Money and cache_fu.
  It supports ActiveRecord 6.0 through 8.x. Solid Cache is a cache store and does not replace this layer.

  Read-Through: Queries by ID, like current_user.articles.find(params[:id]), will first look in cache store and then look in the database for the results of that query. If there is a cache miss, it will populate the cache.

  Write-Through: As objects are created, updated, and deleted, all of the caches are automatically kept up-to-date and coherent.
  SUMMARY

  gem.homepage = "https://github.com/hooopo/second_level_cache"

  gem.files = Dir.glob("lib/**/*.rb") + [
    "README.md",
    "LICENSE",
    "Rakefile",
    "Gemfile",
    "CHANGELOG.md",
    "second_level_cache.gemspec"
  ]
  gem.test_files = Dir.glob("test/**/*.rb")
  gem.executables = gem.files.grep(%r{^bin/})
  gem.name = "second_level_cache"
  gem.require_paths = ["lib"]
  gem.version = SecondLevelCache::VERSION

  gem.add_dependency "activerecord", ">= 6.0"
  gem.add_dependency "activesupport", ">= 6.0"

  gem.add_development_dependency "database_cleaner"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rubocop"
end
