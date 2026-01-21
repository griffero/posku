# frozen_string_literal: true

class HoldExpirationJob < ApplicationJob
  queue_as :default

  def perform(reservation_id)
    reservation = Reservation.find_by(id: reservation_id)
    return unless reservation

    # Only expire if still in held status and past expiration time
    return unless reservation.status == "held"
    return if reservation.hold_expires_at.present? && reservation.hold_expires_at > Time.current

    Rails.logger.info "Expiring hold for reservation #{reservation.locator_code}"
    reservation.expire_hold!
  end
end
