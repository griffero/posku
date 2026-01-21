# frozen_string_literal: true

class PaymentExpirationJob < ApplicationJob
  queue_as :default

  def perform(payment_intent_id)
    payment_intent = PaymentIntent.find_by(id: payment_intent_id)
    return unless payment_intent

    # Only expire if still pending and past expiration time
    return unless %w[created pending].include?(payment_intent.status)
    return if payment_intent.expires_at.present? && payment_intent.expires_at > Time.current

    Rails.logger.info "Expiring payment intent #{payment_intent.external_id}"

    fintoc = FintocMockService.new
    fintoc.simulate_expiration(payment_intent)
  end
end
