require 'rubygems'
require 'bundler/setup'
require 'second_level_cache'
require 'test/unit'

$redis = Redis.new
