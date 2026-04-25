class JobLockService
  def self.redis
    @redis ||= Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
  end

  def self.acquire(key, ttl: 300)
    redis.set(key, "1", nx: true, ex: ttl)
  end
end