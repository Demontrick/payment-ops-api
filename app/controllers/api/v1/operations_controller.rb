module Api
  module V1
    class OperationsController < ApplicationController

      # -------------------------------------
      # LIST ALL OPERATION LOGS
      # -------------------------------------
      def index
        logs = OperationLog.order(created_at: :desc).limit(100)

        render json: logs
      end

      # -------------------------------------
      # FILTER BY PAYMENT
      # -------------------------------------
      def show
        logs = OperationLog.where(payment_id: params[:id])

        render json: logs
      end
    end
  end
end