class FraudDetectionWorker
  include Sidekiq::Worker

  def perform(payment_id)
    payment = Payment.find(payment_id)

    # ----------------------------
    # IDENTITY GUARD (IMPORTANT)
    # Prevent re-processing already handled payments
    # ----------------------------
    return unless payment.status == "pending"

    # ----------------------------
    # RISK CALCULATION (POC LOGIC)
    # ----------------------------
    risk_score = calculate_risk(payment)

    payment.update!(risk_score: risk_score)

    # ----------------------------
    # DECIDE NEXT STATE (BUSINESS LOGIC ONLY)
    # ----------------------------
    next_state = risk_score > 75 ? "flagged" : "fraud_checked"

    # ----------------------------
    # DELEGATE STATE CHANGE TO BRAIN
    # ----------------------------
    PaymentStateEngine.move_to!(
      payment.id,
      next_state,
      worker: self.class.name,
      meta: {
        risk_score: risk_score
      }
    )

    # ----------------------------
    # AUDIT LOG (EXTRA TRACEABILITY)
    # ----------------------------
    OperationLog.create!(
      payment_id: payment.id,
      action: "fraud_check",
      result: next_state == "flagged" ? "high_risk" : "clean",
      worker_type: self.class.name
    )
  end

  private

  def calculate_risk(payment)
    score = 0

    score += 50 if payment.amount.to_f > 10_000
    score += 30 if payment.currency != "USD"
    score += rand(0..30) # simulate uncertainty layer

    score
  end
end