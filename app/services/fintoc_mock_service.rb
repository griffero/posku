# frozen_string_literal: true

class FintocMockService
  class PaymentError < StandardError; end

  # Create a new payment intent for a reservation
  def create_payment_intent(reservation)
    raise PaymentError, "Reservation must be held" unless reservation.status == "held"
    raise PaymentError, "Reservation has no amount" if reservation.total_amount_cents <= 0

    PaymentIntent.create!(
      reservation: reservation,
      provider: "fintoc_mock",
      status: "created",
      amount_cents: reservation.total_amount_cents,
      currency: reservation.currency,
      metadata: {
        locator_code: reservation.locator_code,
        trip_id: reservation.trip_id,
        seats: reservation.reservation_seats.pluck(:seat_number)
      }
    )
  end

  # Simulate starting the payment (user clicked "Pay")
  def start_payment(payment_intent)
    raise PaymentError, "Payment already processed" unless payment_intent.status == "created"

    payment_intent.mark_as_pending!
    payment_intent
  end

  # Simulate payment webhook - succeeded
  def simulate_success(payment_intent)
    raise PaymentError, "Invalid payment state" unless %w[created pending].include?(payment_intent.status)

    payment_intent.mark_as_succeeded!
    payment_intent
  end

  # Simulate payment webhook - failed
  def simulate_failure(payment_intent)
    raise PaymentError, "Invalid payment state" unless %w[created pending].include?(payment_intent.status)

    payment_intent.mark_as_failed!
    payment_intent
  end

  # Simulate payment expiration
  def simulate_expiration(payment_intent)
    return if payment_intent.status == "succeeded"

    payment_intent.mark_as_expired!
    payment_intent
  end

  # Check if payment is completed
  def payment_completed?(payment_intent)
    payment_intent.status == "succeeded"
  end

  # Get payment status info for frontend
  def payment_status(payment_intent)
    {
      id: payment_intent.external_id,
      status: payment_intent.status,
      amount: payment_intent.formatted_amount,
      amount_cents: payment_intent.amount_cents,
      currency: payment_intent.currency,
      expires_at: payment_intent.expires_at,
      expired: payment_intent.expired?,
      payment_url: payment_intent.payment_url,
      created_at: payment_intent.created_at
    }
  end
end
