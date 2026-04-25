class PaymentStateEngine
  # ---------------------------------------------
  # 1. STATE TRANSITIONS (source of truth)
  # ---------------------------------------------
  TRANSITIONS = {
    "pending" => ["fraud_checked", "flagged", "failed"],
    "fraud_checked" => ["risk_assessed", "flagged"],
    "risk_assessed" => ["approved", "failed"],
    "flagged" => ["failed"],
    "failed" => ["pending"]
  }.freeze

  # ---------------------------------------------
  # 2. EVENT MAP (WORKFLOW TRIGGERS)
  # ---------------------------------------------
  EVENT_MAP = {
    "pending" => "payment.created",
    "fraud_checked" => "fraud.completed",
    "risk_assessed" => "risk.completed",
    "flagged" => "payment.flagged",
    "failed" => "payment.failed"
  }.freeze

  # ---------------------------------------------
  # 3. VALIDATION
  # ---------------------------------------------
  def self.can_transition?(payment, next_state)
    allowed = TRANSITIONS[payment.status] || []
    allowed.include?(next_state)
  end

  # ---------------------------------------------
  # 4. CORE BRAIN (SAFE + IDEMPOTENT)
  # ---------------------------------------------
  def self.transition!(payment, next_state, meta: {})
    return payment if payment.status == next_state

    unless can_transition?(payment, next_state)
      raise StandardError, "INVALID TRANSITION: #{payment.status} → #{next_state}"
    end

    ActiveRecord::Base.transaction do
      payment.update!(
        status: next_state,
        updated_at: Time.current
      )

      log_transition(payment, next_state, meta)

      # IMPORTANT: event trigger AFTER commit safety
      enqueue_event(payment.id, next_state)

      payment
    end
  end

  # ---------------------------------------------
  # 5. EVENT DISPATCHER (DECOUPLED + SAFE)
  # ---------------------------------------------
  def self.enqueue_event(payment_id, state)
    event = EVENT_MAP[state]
    return unless event

    case event
    when "payment.created"
      FraudDetectionWorker.perform_async(payment_id)

    when "fraud.completed"
      RiskSummaryWorker.perform_async(payment_id)

    when "risk.completed"
      # terminal state

    when "payment.flagged"
      # optional alert hook

    when "payment.failed"
      PaymentRetryWorker.perform_async(payment_id)
    end
  end

  # ---------------------------------------------
  # 6. AUDIT LOGGING (SINGLE SOURCE OF TRUTH)
  # ---------------------------------------------
  def self.log_transition(payment, next_state, meta)
    OperationLog.create!(
      payment_id: payment.id,
      action: "state_transition",
      result: next_state,
      worker_type: meta[:worker] || "PaymentStateEngine"
    )
  end

  # ---------------------------------------------
  # 7. SAFE ENTRY POINT
  # ---------------------------------------------
def self.move_to!(payment_id, next_state, worker: nil, meta: {})
  payment = Payment.find(payment_id)

  transition!(
    payment,
    next_state,
    meta: { worker: worker }.merge(meta || {})
  )
end

  # ---------------------------------------------
  # 8. WORKFLOW STARTER (FIXED)
  # ---------------------------------------------
  def self.kickoff_workflow!(payment)
    return if payment.status != "pending"

    enqueue_event(payment.id, "pending")
  end
end