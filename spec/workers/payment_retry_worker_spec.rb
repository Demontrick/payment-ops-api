require 'rails_helper'

RSpec.describe PaymentRetryWorker, type: :worker do
  let(:payment) do
    Payment.create!(
      merchant_id: "retry_test",
      amount: 1000,
      currency: "USD",
      status: "failed",
      retry_count: 0
    )
  end

  it "increments retry count" do
    described_class.new.perform(payment.id)

    expect(payment.reload.retry_count).to eq(1)
  end

  it "does not exceed max retries" do
    payment.update!(retry_count: 3)

    described_class.new.perform(payment.id)

    expect(payment.reload.retry_count).to eq(3)
  end
end