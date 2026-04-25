require 'rails_helper'

RSpec.describe FraudDetectionWorker, type: :worker do
  let(:payment) do
    Payment.create!(
      merchant_id: "m1",
      amount: amount,
      currency: currency
    )
  end

  describe "#perform" do
    context "high risk payment" do
      let(:amount) { 20000 }
      let(:currency) { "EUR" }

      it "flags payment" do
        described_class.new.perform(payment.id)

        expect(payment.reload.status).to eq("flagged")
        expect(payment.risk_score).to be > 75
      end
    end

    context "normal payment" do
      let(:amount) { 100 }
      let(:currency) { "USD" }

      it "marks fraud_checked" do
        described_class.new.perform(payment.id)

        expect(payment.reload.status).to eq("fraud_checked")
      end
    end
  end
end