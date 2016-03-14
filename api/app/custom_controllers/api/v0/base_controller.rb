module Api
  module V0
    class BaseController < ActionController::API
      before_filter :allow_cors
      before_filter :validate_request!
      before_filter :authenticate_user!, except: [:check]

      rescue_from StandardError do |e|
        render json: {code: "EXCEPTION", message: "You request raised an exception: #{e.message}"}, status: 500
      end

      def allow_cors
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = %w{GET POST PUT DELETE}.join(",")
        headers["Access-Control-Allow-Headers"] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token X-API-Auth-Token}.join(",")
      end

      def options
        head(:ok)
      end

      def current_user
        @current_user ||= User.where(token: params[:token]).first
      end

      def authenticate_user!
        render_error(code: "AUTHENTICATION_FAILED", message: "Could not authenticate user", status: 401) unless current_user
      end

      def validate_request!
        begin
          Validators::ApiRequestValidator.new(params: params, headers: headers, env: request.env).validate!
        rescue Validators::UnauthorisedApiKeyError => e
          Rails.logger.error e
          return render json: {message: 'Missing API Key or invalid key'}, status: 426
        end
      end

      def check
        render json: {status: :ok}
      end

      def error_404
        render_error(code: "PAGE_NOT_FOUND", message: "The endpoint you called doesn't exist", status: 404)
      end

      def render_error(code:, message:, status:)
        render json: {"error":{"code":code, "message":message}}, status: status
      end
    end
  end
end
