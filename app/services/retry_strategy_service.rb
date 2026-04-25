class RetryStrategyService
  def self.backoff(retry_count)
    2 ** retry_count
  end
end