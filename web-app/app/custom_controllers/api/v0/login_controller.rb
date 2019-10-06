module Api
  module V0
    class LoginController < Api::V0::BaseController
      skip_before_action :authenticate_user!, only: [:create]

      #curl -X POST -H "X-API-KEY:c2606a40f9cd" -H "Content-Type: application/json" -d '{"user":{"email":"foo@bar.com","password":"foobar1234"}}' "http://localhost:3000/api/v0/users/signin"
      def create
        authenticator = UserServices::UserAuthenticator.new(
          email: user_params[:email],
          password: user_params[:password]
        )
        authenticator.authenticate do |on|
          on.success do |user|
            render json: Api::V0::UserSerializer.render(
              object: user,
              include_root: true
            )
          end

          on.failure do |user|
            render_error(code: "CANNOT_SIGNIN_USER", message: "Cannot signin user", status: 401)
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
