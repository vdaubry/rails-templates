module Api
  module V0
    class RegisterController < Api::V0::BaseController
      skip_before_action :authenticate_user!, only: [:create]

      #curl -X POST -H "X-API-KEY:c2606a40f9cd" -H "Content-Type: application/json" -d '{ "user": { "email": "foo@bar.com", "password": "foobar123"} }' "http://localhost:3000/api/v0/users/signup"
      def create
        user_builder = Builders::CreateUser.new(params: user_params)
        user_builder.create do |on|
          on.success do |user|
            render json: Api::V0::UserSerializer.render(
              object: user,
              include_root: true
            ), status: 201
          end

          on.failure do |user|
            render_error(code: "CANNOT_CREATE_USER", message: user.errors.full_messages.join(", "), status: 400)
          end
        end
      end

      private
      def user_params
         params.
           require(:user).
           permit(
             :email,
             :password,
             :first_name,
             :last_name,
           )
      end
    end
  end
end
