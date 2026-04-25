source "https://rubygems.org"

# Rails core
gem "rails", "~> 7.1.0"
gem "pg"
gem "puma"
gem "bootsnap", require: false
gem "tzinfo-data"

# Background jobs (GoCardless-style ops system)
gem "sidekiq"
gem "sidekiq-throttled"
gem "redis"
gem "connection_pool", "~> 2.4"

# HTTP + API integrations
gem "faraday"
gem "dotenv-rails"

# Development / testing
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

# Optional (better logging/debugging)
group :development do
  gem "pry"
  gem "listen"
end