class OperationLog < ApplicationRecord
  belongs_to :payment

  validates :action, :result, :worker_type, presence: true
end