# frozen_string_literal: true

module Api
  class TicketsController < BaseController
    def show
      reservation = Reservation.includes(
        :passengers,
        :reservation_seats,
        trip: { bus: [], route: [:origin_terminal, :destination_terminal] }
      ).find_by!(locator_code: params[:locator])

      unless reservation.status == "confirmed"
        render json: { error: "Ticket not available", message: "La reserva no está confirmada" }, status: :unprocessable_entity
        return
      end

      pdf = TicketPdfService.new(reservation).generate

      send_data pdf,
                filename: "pasaje_#{reservation.locator_code}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end
  end
end
