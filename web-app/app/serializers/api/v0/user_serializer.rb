module Api
  module V0
    class UserSerializer < Api::V0::BaseSerializer

      def json
        {
          id: object.id,
          first_name: object.first_name,
          last_name: object.last_name,
          email: object.email,
          token: object.token,
          refresh_token: object.refresh_token,
        }
      end
    end
  end
end
