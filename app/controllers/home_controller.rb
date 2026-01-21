# frozen_string_literal: true

class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    # Renders the Vue SPA shell
  end
end
