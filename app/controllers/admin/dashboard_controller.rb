# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_terminals: Terminal.count,
        total_routes: Route.count,
        total_buses: Bus.count,
        total_trips: Trip.count,
        upcoming_trips: Trip.where("departure_at > ?", Time.current).count,
        total_reservations: Reservation.count,
        confirmed_reservations: Reservation.confirmed.count,
        pending_reservations: Reservation.held.count,
        today_departures: Trip.for_date(Date.current).count,
        revenue_today: Reservation.confirmed
                                  .joins(:trip)
                                  .where(trips: { departure_at: Date.current.beginning_of_day..Date.current.end_of_day })
                                  .sum(:total_amount_cents)
      }

      @recent_reservations = Reservation.includes(trip: { route: [:origin_terminal, :destination_terminal] })
                                        .order(created_at: :desc)
                                        .limit(10)

      @upcoming_trips = Trip.includes(:bus, route: [:origin_terminal, :destination_terminal])
                           .where("departure_at > ?", Time.current)
                           .order(:departure_at)
                           .limit(10)
    end
  end
end
