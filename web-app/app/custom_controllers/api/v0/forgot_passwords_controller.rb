module Api
  module V0
    class ForgotPasswordsController < Api::V0::BaseController
      skip_before_action :authenticate_user!

      #curl -X POST -H "X-API-KEY:adc86c761fa8" -H "Content-Type: application/json" -d '{"email":"vdaubry@gmail.com"}' "http://localhost:3000v0/password/recover"
      def create
        user = User.where(email: params[:email]).first
        if user
          ResetPasswordJob.perform_later(user.id)
          render json: {status: :ok}.to_json
        else
          render_error(code: "EMAIL_UNKNOWN", message: "Cet email ne correspond à aucun utilisateur connu", status: 401)
        end
      end
    end
  end
end

