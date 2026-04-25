require 'rails_helper'

RSpec.describe PaymentStateEngine do
  let(:payment) do
    Payment.create!(
      merchant_id: "test",
      amount: 5000,
      currency: "USD"
    )
  end

  describe ".transition!" do
    it "allows valid transition" do
      result = described_class.transition!(payment, "fraud_checked")

      expect(result.status).to eq("fraud_checked")
    end

    it "blocks invalid transition" do
      expect {
        described_class.transition!(payment, "approved")
      }.to raise_error(StandardError, /INVALID TRANSITION/)
    end

    it "does nothing if same state" do
      result = described_class.transition!(payment, "pending")
      expect(result.status).to eq("pending")
    end
  end
end