module Api
  module V0
    class UsersController < Api::V0::BaseController
      before_action :validate_user, only: [:show, :update]

      #curl -H "X-API-KEY:adc86c761fa8" -H "Content-Type: application/json" -H "Authorization: Bearer rsedgfhgjh567" "http://localhost:3000/v0/users/1.json"
      def show
        render json: UserSerializer.render(
          object: current_user,
          include_root: true
        )
      end

      #curl -X PATCH -H "X-API-KEY:adc86c761fa8" -H "Content-Type: application/json" -H "Authorization: Bearer rsedgfhgjh567" -d '{"user": {"first_name": "foo"}}' "http://localhost:3000/v0/users/3.json"
      def update
        if current_user.update(user_params)
          render json: UserSerializer.render(
            object: current_user,
            include_root: true
          )
        else
          render_error(code: "USER_UPDATE_ERROR", message: "Cannot update user", status: 400)
        end
      end

      private
      def user_params
        params.require(:user).permit(:email, :first_name, :last_name)
      end

      def validate_user
        super(params[:id])
      end
    end
  end
end
