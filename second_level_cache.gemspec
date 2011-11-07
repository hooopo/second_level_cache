# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["wangxz"]
  gem.email         = ["wangxz@csdn.net"]
  gem.description   = %q{second level cache for rails3}
  gem.summary       = %q{second level cache for rails3}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "second_level_cache"
  gem.require_paths = ["lib"]
  gem.version       = SecondLevelCache::VERSION

  gem.add_runtime_dependency "rails", ["> 3.0"]

  gem.add_development_dependency "activerecord", ["> 3.0"]
  gem.add_development_dependency "redis"
  gem.add_development_dependency "rake"
end
