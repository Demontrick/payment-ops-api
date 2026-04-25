class PaymentRetryWorker
  include Sidekiq::Worker

  MAX_RETRIES = 3

  def perform(payment_id)
    payment = Payment.find_by(id: payment_id)
    return unless payment

    # -----------------------------
    # HARD SAFETY LIMIT (prevents overflow)
    # -----------------------------
    return if payment.retry_count >= MAX_RETRIES

    payment.increment!(:retry_count)

    success = simulate_payment_attempt(payment)

    if success
      PaymentStateEngine.move_to!(
        payment.id,
        "pending",
        worker: self.class.name,
        meta: { retry: "success" }
      )
    else
      if payment.retry_count >= MAX_RETRIES
        PaymentStateEngine.move_to!(
          payment.id,
          "failed",
          worker: self.class.name,
          meta: { retry: "exhausted" }
        )
      else
        PaymentStateEngine.move_to!(
          payment.id,
          "pending",
          worker: self.class.name,
          meta: { retry: "retrying" }
        )

        self.class.perform_in(5 * payment.retry_count, payment.id)
      end
    end
  end

  private

  def simulate_payment_attempt(payment)
    rand > 0.5
  end
end