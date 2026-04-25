class JobLockService
  DEFAULT_TTL = 60 # seconds

  def self.redis
    @redis ||= Redis.new(url: ENV.fetch("REDIS_URL"))
  end

  def self.with_lock(key, ttl: DEFAULT_TTL)
    lock_key = "lock:#{key}"

    acquired = redis.set(lock_key, "1", nx: true, ex: ttl)

    unless acquired
      Rails.logger.info("[LOCK SKIP] #{lock_key} already in progress")
      return :locked
    end

    begin
      yield
    ensure
      redis.del(lock_key)
    end
  end
end