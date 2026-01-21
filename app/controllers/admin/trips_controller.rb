# frozen_string_literal: true

module Admin
  class TripsController < BaseController
    before_action :set_trip, only: [:show, :edit, :update, :destroy, :occupancy]

    def index
      @trips = Trip.includes(:bus, route: [:origin_terminal, :destination_terminal])
                   .order(departure_at: :desc)

      if params[:date].present?
        date = Date.parse(params[:date])
        @trips = @trips.for_date(date)
      elsif params[:upcoming].present?
        @trips = @trips.where("departure_at > ?", Time.current)
      end

      @trips = @trips.page(params[:page]).per(25) if @trips.respond_to?(:page)
    end

    def show
    end

    def new
      @trip = Trip.new
      @routes = Route.active.includes(:origin_terminal, :destination_terminal)
      @buses = Bus.active.order(:name)
    end

    def create
      @trip = Trip.new(trip_params)

      if @trip.save
        create_default_fares(@trip)
        redirect_to admin_trip_path(@trip), notice: "Viaje creado exitosamente"
      else
        @routes = Route.active.includes(:origin_terminal, :destination_terminal)
        @buses = Bus.active.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @routes = Route.active.includes(:origin_terminal, :destination_terminal)
      @buses = Bus.active.order(:name)
    end

    def update
      if @trip.update(trip_params)
        redirect_to admin_trip_path(@trip), notice: "Viaje actualizado exitosamente"
      else
        @routes = Route.active.includes(:origin_terminal, :destination_terminal)
        @buses = Bus.active.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @trip.destroy
      redirect_to admin_trips_path, notice: "Viaje eliminado"
    rescue ActiveRecord::DeleteRestrictionError
      redirect_to admin_trips_path, alert: "No se puede eliminar: tiene reservas asociadas"
    end

    def occupancy
      @occupied_seats = @trip.occupied_seat_numbers
      @reservations = @trip.reservations.includes(:passengers, :reservation_seats).where(status: %w[held confirmed])
    end

    private

    def set_trip
      @trip = Trip.includes(:bus, :fares, route: [:origin_terminal, :destination_terminal]).find(params[:id])
    end

    def trip_params
      params.require(:trip).permit(:route_id, :bus_id, :departure_at, :arrival_at, :status)
    end

    def create_default_fares(trip)
      base_prices = {
        "classic" => 5_000_00,
        "semi_cama" => 8_000_00,
        "salon_cama" => 15_000_00,
        "premium" => 20_000_00
      }

      trip.bus.seats.pluck(:seat_class).uniq.each do |seat_class|
        trip.fares.create!(
          seat_class: seat_class,
          currency: "CLP",
          base_price_cents: base_prices[seat_class] || 5_000_00,
          pricing_rules: {}
        )
      end
    end
  end
end
