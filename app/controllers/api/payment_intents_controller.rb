# frozen_string_literal: true

module Api
  class PaymentIntentsController < BaseController
    before_action :set_payment_intent, only: [:show, :start, :simulate]

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

    # POST /api/payment_intents/:external_id/simulate
    # Simulate payment result (for testing)
    def simulate
      fintoc = FintocMockService.new

      begin
        case params[:action_type] || params[:action]
        when "succeed", "success"
          fintoc.simulate_success(@payment_intent)
          # Confirm the reservation
          @payment_intent.reservation.confirm! if @payment_intent.status == "succeeded"
          message = "Pago exitoso"
        when "fail", "failure"
          fintoc.simulate_failure(@payment_intent)
          message = "Pago fallido"
        when "expire"
          fintoc.simulate_expiration(@payment_intent)
          message = "Pago expirado"
        else
          render json: { error: "Invalid action", message: "Use: succeed, fail, or expire" }, status: :bad_request
          return
        end

        render json: {
          payment_intent: fintoc.payment_status(@payment_intent.reload),
          reservation_status: @payment_intent.reservation.status,
          message: message
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
