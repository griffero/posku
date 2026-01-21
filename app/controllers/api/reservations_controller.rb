# frozen_string_literal: true

module Api
  class ReservationsController < BaseController
    before_action :set_reservation, only: [:show, :update, :checkout, :cancel]

    # POST /api/reservations
    # Create a new reservation with seat hold
    def create
      trip = Trip.find(params[:trip_id])
      seat_numbers = params[:seat_numbers]

      service = SeatHoldService.new(trip)

      begin
        reservation = service.hold_seats(
          seat_numbers,
          contact_email: params[:contact_email],
          contact_phone: params[:contact_phone]
        )

        render json: {
          reservation: reservation_json(reservation),
          message: "Asientos reservados exitosamente"
        }, status: :created
      rescue SeatHoldService::SeatUnavailableError => e
        render json: { error: "Seats unavailable", message: e.message }, status: :conflict
      rescue SeatHoldService::InvalidSeatError => e
        render json: { error: "Invalid seats", message: e.message }, status: :bad_request
      end
    end

    # GET /api/reservations/:locator
    def show
      render json: { reservation: reservation_json(@reservation) }
    end

    # PATCH /api/reservations/:locator
    # Update passengers and contact info
    def update
      service = ReservationService.new(@reservation)

      begin
        # Update contact info
        if params[:contact_email].present? || params[:contact_phone].present?
          service.update_contact(
            email: params[:contact_email] || @reservation.contact_email,
            phone: params[:contact_phone] || @reservation.contact_phone
          )
        end

        # Update passengers
        if params[:passengers].present?
          service.update_passengers(params[:passengers].map(&:to_unsafe_h))
        end

        render json: {
          reservation: reservation_json(@reservation.reload),
          message: "Reserva actualizada"
        }
      rescue ReservationService::ReservationError => e
        render json: { error: "Update failed", message: e.message }, status: :unprocessable_entity
      end
    end

    # POST /api/reservations/:locator/checkout
    def checkout
      service = ReservationService.new(@reservation)

      begin
        payment_intent = service.checkout

        # Schedule payment expiration
        PaymentExpirationJob.set(wait_until: payment_intent.expires_at).perform_later(payment_intent.id)

        render json: {
          payment_intent: payment_intent_json(payment_intent),
          reservation: reservation_json(@reservation)
        }
      rescue ReservationService::ReservationError => e
        render json: { error: "Checkout failed", message: e.message }, status: :unprocessable_entity
      rescue FintocMockService::PaymentError => e
        render json: { error: "Payment error", message: e.message }, status: :unprocessable_entity
      end
    end

    # DELETE /api/reservations/:locator
    def cancel
      if @reservation.status == "confirmed"
        render json: { error: "Cannot cancel confirmed reservation" }, status: :unprocessable_entity
        return
      end

      @reservation.cancel!

      render json: {
        reservation: reservation_json(@reservation),
        message: "Reserva cancelada"
      }
    end

    private

    def set_reservation
      @reservation = Reservation.includes(:trip, :reservation_seats, :passengers, :payment_intents)
                                .find_by!(locator_code: params[:locator])
    end

    def reservation_json(reservation)
      service = ReservationService.new(reservation)
      summary = service.summary

      summary.merge(
        id: reservation.id,
        created_at: reservation.created_at
      )
    end

    def payment_intent_json(payment_intent)
      fintoc = FintocMockService.new
      fintoc.payment_status(payment_intent)
    end
  end
end
