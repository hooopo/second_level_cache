SecondLevelCache.configure do |config|
  config.cache_store = Rails.cache
  config.logger = Rails.logger
end
