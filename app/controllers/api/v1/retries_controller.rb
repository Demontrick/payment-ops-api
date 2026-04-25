module Api
  module V1
    class RetriesController < ApplicationController

      # -------------------------------------
      # MANUAL RETRY TRIGGER
      # -------------------------------------
      def create
        payment = Payment.find(params[:id])

        PaymentRetryWorker.perform_async(payment.id)

        render json: {
          message: "Retry triggered",
          payment_id: payment.id
        }
      end
    end
  end
end