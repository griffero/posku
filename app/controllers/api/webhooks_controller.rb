# frozen_string_literal: true

module Api
  class WebhooksController < BaseController
    # POST /api/webhooks/fintoc_mock
    # Simulate Fintoc webhook callbacks
    def fintoc_mock
      external_id = params[:payment_intent_id]
      event_type = params[:event_type] # succeeded, failed, expired

      payment_intent = PaymentIntent.find_by!(external_id: external_id)
      fintoc = FintocMockService.new

      case event_type
      when "succeeded"
        fintoc.simulate_success(payment_intent)
        message = "Pago confirmado"
      when "failed"
        fintoc.simulate_failure(payment_intent)
        message = "Pago fallido"
      when "expired"
        fintoc.simulate_expiration(payment_intent)
        message = "Pago expirado"
      else
        render json: { error: "Unknown event type" }, status: :bad_request
        return
      end

      render json: {
        payment_intent: fintoc.payment_status(payment_intent),
        message: message
      }
    rescue FintocMockService::PaymentError => e
      render json: { error: "Webhook processing failed", message: e.message }, status: :unprocessable_entity
    end
  end
end
