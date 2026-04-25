class RiskSummaryWorker
  include Sidekiq::Worker

  def perform(payment_id)
    payment = Payment.find(payment_id)

    OperationLog.create!(
      payment_id: payment.id,
      action: "risk_summary",
      result: "generated",
      worker_type: self.class.name
    )
  end
end