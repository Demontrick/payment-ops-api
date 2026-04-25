FactoryBot.define do
  factory :operation_log do
    payment { nil }
    action { "created" }
    result { "success" }
    worker_type { "PaymentRetryWorker" }
  end
end