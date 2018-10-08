module Api
  module V0
    class BaseController < ApplicationController
      DEFAULT_PAGE_COUNT=25
      protect_from_forgery with: :null_session
      before_action :allow_cors
      before_action :validate_request!
      before_action :authenticate_user!

      def allow_cors
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = %w{GET POST PUT DELETE}.join(",")
        headers["Access-Control-Allow-Headers"] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token X-API-Auth-Token}.join(",")
      end

      def options
        head(:ok)
      end

      def token
        bearer && bearer.split("Bearer ")[1]
      end

      def current_user
        @current_user ||= User.where("token = ? OR refresh_token = ?", token, token).first
      end

      def authenticate_user!
        return render json: {message: 'unauthorized'}, status: :unauthorized unless current_user
      end

      def validate_request!
        begin
          Validators::ApiRequestValidator.new(params: params, headers: request.headers, env: request.env).validate!
        rescue Validators::UnauthorisedApiKeyError => e
          Rails.logger.error e
          return render json: {message: 'Missing API Key or invalid key'}, status: 426
        end
      end

      def render_error(code:, message:, status:)
        messages = [message] unless message.is_a?(Array)
        render json: { "error": { "code": code, "messages": messages } }, status: status
      end

      def offset
        params[:offset].try(:to_i) || 0
      end

      def count
        [(params[:count].try(:to_i) || DEFAULT_PAGE_COUNT), DEFAULT_PAGE_COUNT].min
      end

      def check
        render json: {status: :ok}
      end

      private
      def bearer
        request.env['Authorization'] || request.env['HTTP_AUTHORIZATION'] || params[:token]
      end
    end
  end
end
