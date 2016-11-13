module Api
  module V0
    class UsersController < Api::V0::BaseController
      skip_before_action :authenticate_user!, only: [:login]

      def login
        user = UserServices::UserAuthenticator.authenticate(login: user_params[:login], password: user_params[:password])
        return render json: {message: 'unauthorized'}, status: :unauthorized unless user

        render json: user, status: 200
      end

      private
      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
