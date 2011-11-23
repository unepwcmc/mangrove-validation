module Cash
  class Lock
    class Error < RuntimeError; end

    INITIAL_WAIT = 2
    DEFAULT_RETRY = 8
    DEFAULT_EXPIRY = 30

    def initialize(cache)
      @cache = cache
    end

    def synchronize(key, lock_expiry = DEFAULT_EXPIRY, retries = DEFAULT_RETRY, initial_wait = INITIAL_WAIT)
      if recursive_lock?(key)
        yield
      else
        acquire_lock(key, lock_expiry, retries, initial_wait)
        begin
          yield
        ensure
          release_lock(key)
        end
      end
    end

    def acquire_lock(key, lock_expiry = DEFAULT_EXPIRY, retries = DEFAULT_RETRY, initial_wait = INITIAL_WAIT)
      retries.times do |count|
        response = @cache.add("lock/#{key}", Process.pid, lock_expiry)
        return if response == "STORED\r\n"
        exponential_sleep(count, initial_wait) unless count == retries - 1
      end
      debug_lock(key)
      raise Error, "Couldn't acquire memcache lock for: #{key}   server: #{@cache.get_server_for_key(key)}"
    end

    def release_lock(key)
      @cache.delete("lock/#{key}")
    end

    def exponential_sleep(count, initial_wait)
      sleep((2**count) / initial_wait)
    end

    private

    def recursive_lock?(key)
      @cache.get("lock/#{key}") == Process.pid
    end

    def debug_lock(key)
      @cache.logger.warn("#{@cache.get("lock/#{key}")}") if @cache.respond_to?(:logger) && @cache.logger.respond_to?(:warn)
    rescue
      @cache.logger.warn("#{$!}") if @cache.respond_to?(:logger) && @cache.logger.respond_to?(:warn)
    end
  end
end
