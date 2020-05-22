# frozen_string_literal: true

module SecondLevelCache
  class LogSubscriber < ActiveSupport::LogSubscriber
    # preload.second_level_cache
    def preload(event)
      prefix = color("SecondLevelCache", CYAN)
      miss_ids = (event.payload[:miss] || []).join(",")
      hit_ids = (event.payload[:hit] || []).join(",")
      debug "  #{prefix} preload #{event.payload[:key]} miss [#{miss_ids}], hit [#{hit_ids}]"
    end
  end
end

SecondLevelCache::LogSubscriber.attach_to :second_level_cache
