# frozen_string_literal: true

class ReservationService
  class ReservationError < StandardError; end

  def initialize(reservation)
    @reservation = reservation
  end

  # Update passenger information
  def update_passengers(passengers_data)
    raise ReservationError, "Reservation is not active" unless %w[held confirmed].include?(@reservation.status)

    Reservation.transaction do
      # Remove existing passengers
      @reservation.passengers.destroy_all

      # Create new passengers
      passengers_data.each do |passenger_data|
        @reservation.passengers.create!(
          first_name: passenger_data[:first_name],
          last_name: passenger_data[:last_name],
          document_type: passenger_data[:document_type],
          document_number: passenger_data[:document_number],
          seat_number: passenger_data[:seat_number]
        )
      end
    end

    @reservation
  end

  # Update contact information
  def update_contact(email:, phone:)
    raise ReservationError, "Reservation is not active" unless %w[held confirmed].include?(@reservation.status)

    @reservation.update!(
      contact_email: email,
      contact_phone: phone
    )

    @reservation
  end

  # Prepare for checkout - validates all required data is present
  def prepare_checkout
    errors = []

    # Check passengers
    seat_count = @reservation.reservation_seats.count
    passenger_count = @reservation.passengers.count

    if passenger_count != seat_count
      errors << "Se requiere información de #{seat_count} pasajero(s), pero solo hay #{passenger_count}"
    end

    # Check contact info
    errors << "Email de contacto requerido" if @reservation.contact_email.blank?
    errors << "Teléfono de contacto requerido" if @reservation.contact_phone.blank?

    # Check hold is still active
    unless @reservation.hold_active?
      errors << "La reserva ha expirado"
    end

    {
      ready: errors.empty?,
      errors: errors
    }
  end

  # Start checkout process
  def checkout
    validation = prepare_checkout
    raise ReservationError, validation[:errors].join(", ") unless validation[:ready]

    # Create payment intent
    fintoc = FintocMockService.new
    payment_intent = fintoc.create_payment_intent(@reservation)

    payment_intent
  end

  # Get reservation summary for display
  def summary
    trip = @reservation.trip
    route = trip.route

    {
      locator_code: @reservation.locator_code,
      status: @reservation.status,
      status_label: @reservation.status_label,
      hold_expires_at: @reservation.hold_expires_at,
      hold_time_remaining: @reservation.hold_time_remaining,
      contact: {
        email: @reservation.contact_email,
        phone: @reservation.contact_phone
      },
      trip: {
        id: trip.id,
        origin: route.origin_terminal.display_name,
        destination: route.destination_terminal.display_name,
        departure_at: trip.departure_at,
        arrival_at: trip.arrival_at,
        bus_type: trip.bus.bus_type_label,
        duration: route.duration_formatted
      },
      seats: @reservation.reservation_seats.map do |rs|
        {
          seat_number: rs.seat_number,
          seat_class: rs.seat_class,
          price_cents: rs.price_cents,
          formatted_price: rs.formatted_price
        }
      end,
      passengers: @reservation.passengers.map do |p|
        {
          full_name: p.full_name,
          document: "#{p.document_type_label}: #{p.document_number}",
          seat_number: p.seat_number
        }
      end,
      total: {
        amount_cents: @reservation.total_amount_cents,
        formatted: @reservation.formatted_total,
        currency: @reservation.currency
      }
    }
  end
end
