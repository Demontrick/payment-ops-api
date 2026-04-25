class EventDispatcher
  def self.dispatch(event, payment_id)
    case event
    when "payment.created"
      FraudDetectionWorker.perform_async(payment_id)

    when "fraud.completed"
      RiskSummaryWorker.perform_async(payment_id)

    when "payment.retry"
      PaymentRetryWorker.perform_async(payment_id)
    end
  end
end