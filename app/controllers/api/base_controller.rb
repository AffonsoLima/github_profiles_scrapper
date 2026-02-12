module Api
  class BaseController < ActionController::API
    include Pagy::Backend

    rescue_from ActiveRecord::RecordNotFound do
      render_error("not_found", "Perfil não encontrado", :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render json: { error: "validation_error", details: error.record.errors.full_messages }, status: :unprocessable_entity
    end

    rescue_from ActionController::ParameterMissing do |error|
      render json: { error: "invalid_parameters", message: error.message }, status: :bad_request
    end

    private

    def render_error(code, message, status)
      render json: { error: code, message: message }, status: status
    end
  end
end
