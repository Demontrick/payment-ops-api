module Api
  module V1
    class PaymentsController < ApplicationController

      # -------------------------------------
      # CREATE PAYMENT (ENTRY POINT)
      # -------------------------------------
      def create
        payment = Payment.create!(payment_params)

        # 🚀 START WORKFLOW THROUGH BRAIN
        PaymentStateEngine.move_to!(
          payment.id,
          "pending",
          worker: "Api::V1::PaymentsController"
        )

        render json: payment, status: :created
      end

      # -------------------------------------
      # SHOW PAYMENT
      # -------------------------------------
      def show
        payment = Payment.find(params[:id])
        render json: payment
      end

      # -------------------------------------
      # MANUAL RETRY (CONTROLLED FLOW)
      # -------------------------------------
      def retry
        payment = Payment.find(params[:id])

        # ❌ DO NOT directly mutate state here
        # payment.increment!(:retry_count)

        # ✔ Send to retry worker instead
        PaymentRetryWorker.perform_async(payment.id)

        render json: {
          message: "Retry queued successfully",
          payment_id: payment.id,
          retry_count: payment.retry_count
        }
      end

      private

      def payment_params
        params.require(:payment).permit(
          :merchant_id,
          :amount,
          :currency
        )
      end
    end
  end
end