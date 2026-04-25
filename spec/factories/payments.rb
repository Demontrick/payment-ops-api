FactoryBot.define do
  factory :payment do
    merchant_id { "merchant_1" }
    amount { 99.99 }
    currency { "USD" }
    status { "pending" }
    failure_reason { nil }
    retry_count { 0 }
    risk_score { 10 }
  end
end