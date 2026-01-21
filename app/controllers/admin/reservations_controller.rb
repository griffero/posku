# frozen_string_literal: true

module Admin
  class ReservationsController < BaseController
    before_action :set_reservation, only: [:show, :cancel]

    def index
      @reservations = Reservation.includes(trip: { route: [:origin_terminal, :destination_terminal] })
                                 .order(created_at: :desc)

      @reservations = @reservations.where(status: params[:status]) if params[:status].present?

      if params[:locator].present?
        @reservations = @reservations.where("locator_code ILIKE ?", "%#{params[:locator]}%")
      end

      if params[:date].present?
        date = Date.parse(params[:date])
        @reservations = @reservations.joins(:trip).where(trips: { departure_at: date.beginning_of_day..date.end_of_day })
      end
    end

    def show
    end

    def cancel
      if @reservation.status == "confirmed"
        @reservation.update!(status: "cancelled")
        @reservation.reservation_seats.update_all(status: "released")
        redirect_to admin_reservation_path(@reservation), notice: "Reserva cancelada"
      else
        @reservation.cancel!
        redirect_to admin_reservation_path(@reservation), notice: "Reserva cancelada"
      end
    end

    def export
      @reservations = Reservation.includes(:passengers, :reservation_seats, trip: { route: [:origin_terminal, :destination_terminal] })
                                 .where(status: "confirmed")

      if params[:date].present?
        date = Date.parse(params[:date])
        @reservations = @reservations.joins(:trip).where(trips: { departure_at: date.beginning_of_day..date.end_of_day })
      end

      respond_to do |format|
        format.csv do
          send_data generate_csv(@reservations),
                    filename: "reservas_#{Date.current}.csv",
                    type: "text/csv"
        end
      end
    end

    private

    def set_reservation
      @reservation = Reservation.includes(:passengers, :reservation_seats, :payment_intents, trip: { route: [:origin_terminal, :destination_terminal] })
                                .find(params[:id])
    end

    def generate_csv(reservations)
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << ["Código", "Estado", "Origen", "Destino", "Fecha Viaje", "Hora Salida", "Pasajeros", "Asientos", "Total", "Email", "Teléfono", "Creado"]

        reservations.each do |r|
          csv << [
            r.locator_code,
            r.status_label,
            r.trip.route.origin_terminal.city,
            r.trip.route.destination_terminal.city,
            r.trip.departure_at.strftime("%Y-%m-%d"),
            r.trip.departure_at.strftime("%H:%M"),
            r.passengers.map(&:full_name).join("; "),
            r.reservation_seats.pluck(:seat_number).join(", "),
            r.formatted_total,
            r.contact_email,
            r.contact_phone,
            r.created_at.strftime("%Y-%m-%d %H:%M")
          ]
        end
      end
    end
  end
end
