# frozen_string_literal: true

class SeatHoldService
  class SeatUnavailableError < StandardError; end
  class InvalidSeatError < StandardError; end

  HOLD_DURATION = Rails.configuration.x.seat_hold_duration || 8.minutes

  def initialize(trip)
    @trip = trip
  end

  # Hold seats for a new reservation
  # Returns the reservation if successful, raises error otherwise
  def hold_seats(seat_numbers, contact_email: nil, contact_phone: nil)
    validate_seats!(seat_numbers)

    Trip.transaction do
      # Lock the trip to prevent race conditions
      @trip.lock!

      # Check seat availability
      unavailable = seat_numbers & @trip.occupied_seat_numbers
      raise SeatUnavailableError, "Seats #{unavailable.join(', ')} are not available" if unavailable.any?

      # Create reservation with hold
      reservation = Reservation.create!(
        trip: @trip,
        status: "held",
        hold_expires_at: HOLD_DURATION.from_now,
        contact_email: contact_email,
        contact_phone: contact_phone,
        currency: "CLP",
        total_amount_cents: 0
      )

      # Create reservation seats
      seat_numbers.each do |seat_number|
        seat = @trip.bus.seats.find_by(seat_number: seat_number)
        fare = @trip.fare_for_seat_class(seat.seat_class)

        reservation.reservation_seats.create!(
          seat_number: seat_number,
          seat_class: seat.seat_class,
          price_cents: fare.calculate_price(date: @trip.departure_at),
          status: "held"
        )
      end

      # Calculate total
      reservation.recalculate_total!

      # Schedule expiration job
      HoldExpirationJob.set(wait_until: reservation.hold_expires_at).perform_later(reservation.id)

      reservation
    end
  end

  # Add seats to an existing held reservation
  def add_seats(reservation, seat_numbers)
    validate_seats!(seat_numbers)
    raise "Reservation is not held" unless reservation.status == "held"

    Trip.transaction do
      @trip.lock!

      # Check if seats are available
      unavailable = seat_numbers & @trip.occupied_seat_numbers
      raise SeatUnavailableError, "Seats #{unavailable.join(', ')} are not available" if unavailable.any?

      seat_numbers.each do |seat_number|
        seat = @trip.bus.seats.find_by(seat_number: seat_number)
        fare = @trip.fare_for_seat_class(seat.seat_class)

        reservation.reservation_seats.create!(
          seat_number: seat_number,
          seat_class: seat.seat_class,
          price_cents: fare.calculate_price(date: @trip.departure_at),
          status: "held"
        )
      end

      reservation.recalculate_total!
      reservation
    end
  end

  # Remove seats from a held reservation
  def remove_seats(reservation, seat_numbers)
    raise "Reservation is not held" unless reservation.status == "held"

    reservation.reservation_seats.where(seat_number: seat_numbers).destroy_all
    reservation.recalculate_total!

    # Cancel reservation if no seats left
    if reservation.reservation_seats.empty?
      reservation.cancel!
    end

    reservation
  end

  private

  def validate_seats!(seat_numbers)
    raise InvalidSeatError, "No seats provided" if seat_numbers.blank?

    valid_seats = @trip.bus.seats.pluck(:seat_number)
    invalid = seat_numbers - valid_seats
    raise InvalidSeatError, "Invalid seat numbers: #{invalid.join(', ')}" if invalid.any?
  end
end
