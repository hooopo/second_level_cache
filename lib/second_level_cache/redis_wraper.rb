# encoding: utf-8
module SecondLevelCache
  class Redis
    def initialize(repository, options = {})
      @repository = repository
      @logger = options[:logger]
      @default_ttl = options[:default_ttl] || raise(":default_ttl is a required option")
    end

    def add(key, value, ttl=nil, raw = false)
      wrap(key, not_stored) do
        logger.debug("Redis add: #{key.inspect}") if debug_logger?
        value = dump(value) unless raw
        # TODO: make transactional
        result = @repository.setnx(key, value)
        @repository.expires(key, ttl || @default_ttl) if true == result
        logger.debug("Redis hit: #{key.inspect}") if debug_logger?
        true == result ? stored : not_stored
      end
    end

    def get(key, raw = false)
      wrap(key) do
        logger.debug("Redis get: #{key.inspect}") if debug_logger?
        value = wrap(key) { @repository.get(key) }
        if value
          logger.debug("Redis hit: #{key.inspect}") if debug_logger?
          value = load(value) unless raw
        else
          logger.debug("Redis miss: #{key.inspect}") if debug_logger?
        end
        value
      end
    end

    def get_multi(*keys)
      wrap(keys, {}) do
        keys.flatten!
        logger.debug("Redis get_multi: #{keys.inspect}") if debug_logger?

        # Values are returned as an array. Convert them to a hash of matches, dropping anything
        # that doesn't have a match.
        values = @repository.mget(*keys)
        result = {}
        keys.each_with_index{ |key, i| result[key] = load(values[i]) if values[i] }

        if result.any?
          logger.debug("Redis hit: #{keys.inspect}") if debug_logger?
        else
          logger.debug("Redis miss: #{keys.inspect}") if debug_logger?
        end
        result
      end
    end

    def set(key, value, ttl=nil, raw = false)
      wrap(key, not_stored) do
        logger.debug("Redis set: #{key.inspect}") if debug_logger?
        value = dump(value) unless raw
        @repository.setex(key, ttl || @default_ttl, value)
        logger.debug("Redis hit: #{key.inspect}") if debug_logger?
        stored
      end
    end

    def delete(key)
      wrap(key, not_found) do
        logger.debug("Redis delete: #{key.inspect}") if debug_logger?
        @repository.del(key)
        logger.debug("Redis hit: #{key.inspect}") if debug_logger?
        deleted
      end
    end

    def incr(key, value = 1)
      # Redis always answeres positively to incr/decr but memcache does not and waits for the key
      # to be added in a separate operation.
      if wrap(nil) { @repository.exists(key) }
        wrap(key) { @repository.incrby(key, value).to_i }
      end
    end

    def decr(key, value = 1)
      if wrap(nil) { @repository.exists(key) }
        wrap(key) { @repository.decrby(key, value).to_i }
      end
    end

    def flush_all
      @repository.flushall
    end

    def exception_classes
      [Errno::ECONNRESET, Errno::EPIPE, Errno::ECONNABORTED, Errno::EBADF, Errno::EINVAL]
    end

    private

    def logger
      @logger
    end

    def debug_logger?
      logger && logger.respond_to?(:debug?) && logger.debug?
    end

    def wrap(key, error_value = nil)
      yield
    rescue *exception_classes
      log_error($!) if logger
      error_value
    end

    def dump(value)
      Marshal.dump(value)
    end

    def load(value)
      Marshal.load(value)
    end

    def stored
      "STORED\r\n"
    end

    def deleted
      "DELETED\r\n"
    end

    def not_stored
      "NOT_STORED\r\n"
    end

    def not_found
      "NOT_FOUND\r\n"
    end

    def log_error(err)
      logger.error("Redis ERROR, #{err.class}: #{err}") if logger
    end
  end
end
