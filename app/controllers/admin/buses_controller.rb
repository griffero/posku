# frozen_string_literal: true

module Admin
  class BusesController < BaseController
    before_action :set_bus, only: [:show, :edit, :update, :destroy]

    def index
      @buses = Bus.order(:name)
    end

    def show
    end

    def new
      @bus = Bus.new
    end

    def create
      @bus = Bus.new(bus_params)

      if @bus.save
        @bus.generate_seats_from_layout! if @bus.seat_layout.present?
        redirect_to admin_bus_path(@bus), notice: "Bus creado exitosamente"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @bus.update(bus_params)
        @bus.generate_seats_from_layout! if @bus.seat_layout.present?
        redirect_to admin_bus_path(@bus), notice: "Bus actualizado exitosamente"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @bus.destroy
      redirect_to admin_buses_path, notice: "Bus eliminado"
    rescue ActiveRecord::DeleteRestrictionError
      redirect_to admin_buses_path, alert: "No se puede eliminar: tiene viajes asociados"
    end

    private

    def set_bus
      @bus = Bus.find(params[:id])
    end

    def bus_params
      params.require(:bus).permit(:name, :bus_type, :plate_number, :total_seats, :active, :seat_layout)
    end
  end
end
