module Api
  module V0
    class SessionsController < Api::V0::BaseController
      skip_before_action :authenticate_user!, only: [:login]

      def login
        user_service = UserServices::UserAuthenticator.new(email: user_params[:email], password: user_params[:password])
        user_service.authenticate do |on|
          on.success do |user|
            render json: user, status: 200
          end
          
          on.failure do
            return render json: {message: 'unauthorized'}, status: 401
          end
        end
      end

      private
      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
