# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    layout "admin"

    private

    def require_admin
      unless Current.user&.admin?
        redirect_to root_path, alert: "Acceso no autorizado"
      end
    end
  end
end
