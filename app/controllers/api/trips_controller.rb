# frozen_string_literal: true

module Api
  class TripsController < BaseController
    def search
      origin = Terminal.find_by(code: params[:origin])
      destination = Terminal.find_by(code: params[:destination])
      
      unless origin
        render json: { error: "Terminal de origen no encontrado" }, status: :not_found
        return
      end
      
      unless destination
        render json: { error: "Terminal de destino no encontrado" }, status: :not_found
        return
      end

      date = Date.parse(params[:date])
      passengers = (params[:passengers] || 1).to_i

      route = Route.active.find_by(
        origin_terminal: origin,
        destination_terminal: destination
      )

      unless route
        render json: {
          search: {
            origin: terminal_json(origin),
            destination: terminal_json(destination),
            date: date,
            passengers: passengers
          },
          trips: [],
          message: "No hay rutas disponibles entre #{origin.city} y #{destination.city}"
        }
        return
      end

      trips = Trip.scheduled
                  .where(route: route)
                  .where(departure_at: date.beginning_of_day..date.end_of_day)
                  .where("departure_at > ?", Time.current)
                  .includes(:bus, :fares, route: [:origin_terminal, :destination_terminal])
                  .order(:departure_at)

      render json: {
        search: {
          origin: terminal_json(origin),
          destination: terminal_json(destination),
          date: date,
          passengers: passengers
        },
        trips: trips.map { |t| trip_search_json(t, passengers) }
      }
    end

    def show
      trip = Trip.includes(:bus, :fares, route: [:origin_terminal, :destination_terminal])
                 .find(params[:id])

      render json: { trip: trip_detail_json(trip) }
    end

    def seats
      trip = Trip.includes(:bus).find(params[:id])
      occupied = trip.occupied_seat_numbers

      seats_data = trip.bus.seats.order(:floor, :row_number, :column_number).map do |seat|
        fare = trip.fare_for_seat_class(seat.seat_class)
        {
          seat_number: seat.seat_number,
          seat_class: seat.seat_class,
          seat_class_label: seat.seat_class_label,
          floor: seat.floor,
          row: seat.row_number,
          column: seat.column_number,
          available: !occupied.include?(seat.seat_number),
          price_cents: fare&.calculate_price(date: trip.departure_at),
          formatted_price: fare&.formatted_price
        }
      end

      render json: {
        trip_id: trip.id,
        bus_type: trip.bus.bus_type,
        bus_type_label: trip.bus.bus_type_label,
        layout: trip.bus.seat_layout,
        total_seats: trip.bus.total_seats,
        available_seats: trip.available_seats_count,
        seats: seats_data
      }
    end

    private

    def terminal_json(terminal)
      {
        id: terminal.id,
        name: terminal.name,
        city: terminal.city,
        code: terminal.code,
        display_name: terminal.display_name
      }
    end

    def trip_search_json(trip, passengers)
      lowest_fare = trip.fares.minimum(:base_price_cents)
      available = trip.available_seats_count

      {
        id: trip.id,
        departure_at: trip.departure_at,
        arrival_at: trip.arrival_at,
        duration_minutes: trip.route.duration_minutes,
        duration_formatted: trip.route.duration_formatted,
        bus_type: trip.bus.bus_type,
        bus_type_label: trip.bus.bus_type_label,
        available_seats: available,
        has_availability: available >= passengers,
        price_from_cents: lowest_fare,
        price_from_formatted: format_clp(lowest_fare),
        origin: {
          name: trip.route.origin_terminal.name,
          city: trip.route.origin_terminal.city
        },
        destination: {
          name: trip.route.destination_terminal.name,
          city: trip.route.destination_terminal.city
        }
      }
    end

    def trip_detail_json(trip)
      {
        id: trip.id,
        departure_at: trip.departure_at,
        arrival_at: trip.arrival_at,
        status: trip.status,
        status_label: trip.status_label,
        route: {
          id: trip.route.id,
          origin: terminal_json(trip.route.origin_terminal),
          destination: terminal_json(trip.route.destination_terminal),
          distance_km: trip.route.distance_km,
          duration_minutes: trip.route.duration_minutes,
          duration_formatted: trip.route.duration_formatted
        },
        bus: {
          name: trip.bus.name,
          type: trip.bus.bus_type,
          type_label: trip.bus.bus_type_label,
          total_seats: trip.bus.total_seats
        },
        fares: trip.fares.map do |f|
          {
            seat_class: f.seat_class,
            price_cents: f.base_price_cents,
            formatted_price: f.formatted_price
          }
        end,
        available_seats: trip.available_seats_count
      }
    end

    def format_clp(cents)
      "$#{cents.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}"
    end
  end
end
