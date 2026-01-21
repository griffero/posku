# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    allow_unauthenticated_access
    skip_before_action :verify_authenticity_token
    before_action :set_default_format

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request

    private

    def set_default_format
      request.format = :json
    end

    def not_found(exception)
      render json: { error: "Not found", message: exception.message }, status: :not_found
    end

    def unprocessable_entity(exception)
      render json: { error: "Validation failed", messages: exception.record.errors.full_messages }, status: :unprocessable_entity
    end

    def bad_request(exception)
      render json: { error: "Bad request", message: exception.message }, status: :bad_request
    end
  end
end
