module Api
  module V0
    class BaseController < ApplicationController
      DEFAULT_PAGE_COUNT=25
      
      before_action :allow_cors
      before_action :validate_request!
      before_action :authenticate_user!, except: [:check]
      before_action :set_language

      def allow_cors
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = %w{GET POST PUT DELETE}.join(",")
        headers["Access-Control-Allow-Headers"] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token X-API-Auth-Token}.join(",")
      end

      def options
        head(:ok)
      end

      def current_user
        @current_user ||= User.where(token: token).first
      end

      def token
        bearer && bearer.split("Bearer ")[1]
      end

      def authenticate_user!
        render_error(code: "AUTHENTICATION_FAILED", message: "Could not authenticate user", status: 401) unless current_user
      end

      def validate_request!
        begin
          Validators::ApiRequestValidator.new(params: params, headers: request.headers, env: request.env).validate!
        rescue Validators::UnauthorisedApiKeyError => e
          Rails.logger.error e
          return render json: {message: 'Missing API Key or invalid key'}, status: 426
        end
      end

      def check
        render json: {status: :ok}
      end

      def render_error(code:, message:, status:)
        render json: {"error":{"code":code, "message":message}}, status: status
      end
      
      def offset
        params[:offset].try(:to_i) || 0
      end

      def count
        [(params[:count].try(:to_i) || DEFAULT_PAGE_COUNT), DEFAULT_PAGE_COUNT].min
      end


      private
      def bearer
        request.env['Authorization'] || request.env['HTTP_AUTHORIZATION'] || params[:token]
      end
      
      def set_language
        if current_user
          if request.env['Accept-Language'].present? &&
              (current_user.language.nil? || current_user.language != request.env['Accept-Language'])
            current_user.update(language: request.env['Accept-Language'])
          end

          I18n.locale = current_user.language || "en"
        end
      end
    end
  end
end
