# frozen_string_literal: true

module Admin
  class TerminalsController < BaseController
    before_action :set_terminal, only: [:show, :edit, :update, :destroy]

    def index
      @terminals = Terminal.order(:city, :name)
    end

    def show
    end

    def new
      @terminal = Terminal.new
    end

    def create
      @terminal = Terminal.new(terminal_params)

      if @terminal.save
        redirect_to admin_terminal_path(@terminal), notice: "Terminal creado exitosamente"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @terminal.update(terminal_params)
        redirect_to admin_terminal_path(@terminal), notice: "Terminal actualizado exitosamente"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @terminal.destroy
      redirect_to admin_terminals_path, notice: "Terminal eliminado"
    rescue ActiveRecord::DeleteRestrictionError
      redirect_to admin_terminals_path, alert: "No se puede eliminar: tiene rutas asociadas"
    end

    private

    def set_terminal
      @terminal = Terminal.find(params[:id])
    end

    def terminal_params
      params.require(:terminal).permit(:name, :city, :code, :latitude, :longitude, :active)
    end
  end
end
