class Payment < ApplicationRecord
  has_many :operation_logs, dependent: :destroy

  # ---------------------------------------------
  # STATE MACHINE COMPATIBLE STATUSES
  # ---------------------------------------------
  STATUSES = %w[
    pending
    fraud_checked
    risk_assessed
    approved
    flagged
    failed
  ].freeze

  validates :merchant_id, :amount, :currency, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_defaults, on: :create

  # ---------------------------------------------
  # AUTO WORKFLOW ENTRY POINT
  # ---------------------------------------------
  after_create_commit :trigger_fraud_detection

  private

  def set_defaults
    self.status ||= "pending"
    self.retry_count ||= 0
    self.risk_score ||= 0
  end

  # ---------------------------------------------
  # BOOTSTRAP WORKFLOW
  # ---------------------------------------------
  def trigger_fraud_detection
    FraudDetectionWorker.perform_async(id)
  end
end