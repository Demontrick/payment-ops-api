class FraudDetectionWorker
  include Sidekiq::Worker

  def perform(payment_id)
    JobLockService.with_lock("payment:#{payment_id}:fraud") do
      payment = Payment.find_by(id: payment_id)
      return unless payment

      # Prevent reprocessing if already advanced
      return unless payment.status == "pending"

      risk_score = calculate_risk(payment)
      payment.update!(risk_score: risk_score)

      next_state =
        if risk_score > 75
          "flagged"
        else
          "fraud_checked"
        end

      PaymentStateEngine.move_to!(
        payment.id,
        next_state,
        worker: self.class.name,
        meta: { risk_score: risk_score }
      )
    end
  end

  private

  def calculate_risk(payment)
    score = 0
    score += 50 if payment.amount.to_f > 10_000
    score += 30 if payment.currency != "USD"
    score += rand(0..30)
    score
  end
end