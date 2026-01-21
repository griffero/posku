# frozen_string_literal: true

module Admin
  class RoutesController < BaseController
    before_action :set_route, only: [:show, :edit, :update, :destroy]

    def index
      @routes = Route.includes(:origin_terminal, :destination_terminal).order("origin_terminals_routes.city")
    end

    def show
    end

    def new
      @route = Route.new
      @terminals = Terminal.active.order(:city, :name)
    end

    def create
      @route = Route.new(route_params)

      if @route.save
        redirect_to admin_route_path(@route), notice: "Ruta creada exitosamente"
      else
        @terminals = Terminal.active.order(:city, :name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @terminals = Terminal.active.order(:city, :name)
    end

    def update
      if @route.update(route_params)
        redirect_to admin_route_path(@route), notice: "Ruta actualizada exitosamente"
      else
        @terminals = Terminal.active.order(:city, :name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @route.destroy
      redirect_to admin_routes_path, notice: "Ruta eliminada"
    rescue ActiveRecord::DeleteRestrictionError
      redirect_to admin_routes_path, alert: "No se puede eliminar: tiene viajes asociados"
    end

    private

    def set_route
      @route = Route.includes(:origin_terminal, :destination_terminal).find(params[:id])
    end

    def route_params
      params.require(:route).permit(:origin_terminal_id, :destination_terminal_id, :distance_km, :duration_minutes, :active)
    end
  end
end
