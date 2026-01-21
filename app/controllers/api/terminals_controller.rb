# frozen_string_literal: true

module Api
  class TerminalsController < BaseController
    def index
      terminals = Terminal.active.order(:city, :name)

      render json: {
        terminals: terminals.map { |t| terminal_json(t) }
      }
    end

    def show
      terminal = Terminal.find(params[:id])
      render json: { terminal: terminal_json(terminal) }
    end

    private

    def terminal_json(terminal)
      {
        id: terminal.id,
        name: terminal.name,
        city: terminal.city,
        code: terminal.code,
        display_name: terminal.display_name,
        latitude: terminal.latitude,
        longitude: terminal.longitude
      }
    end
  end
end
