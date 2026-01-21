# frozen_string_literal: true

module Api
  class PaymentIntentsController < BaseController
    before_action :set_payment_intent, only: [:show, :start]

    # GET /api/payment_intents/:external_id
    def show
      fintoc = FintocMockService.new
      render json: { payment_intent: fintoc.payment_status(@payment_intent) }
    end

    # POST /api/payment_intents/:external_id/start
    # Simulate user clicking "Pay" button
    def start
      fintoc = FintocMockService.new

      begin
        fintoc.start_payment(@payment_intent)
        render json: {
          payment_intent: fintoc.payment_status(@payment_intent),
          message: "Pago iniciado"
        }
      rescue FintocMockService::PaymentError => e
        render json: { error: "Payment error", message: e.message }, status: :unprocessable_entity
      end
    end

    private

    def set_payment_intent
      @payment_intent = PaymentIntent.find_by!(external_id: params[:external_id])
    end
  end
end
