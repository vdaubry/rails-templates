module Api
  module V0
    #curl -H "X-API-KEY:adc86c761fa8" -H "Content-Type: application/json" -H 'Accept-Language: fr-FR' -H "Content-Type: application/json" "http://localhost:3000/v0/config.json"
    class ConfigController < Api::V0::BaseController
      skip_before_action :authenticate_user!

      def index
        response.headers["Cache-Control"] = "public, max-age=600"
        render json: config_json, status: 200
      end

      private
      def config_json
        {
          "config": {
            "cgu_url": "http://www.1job1passion.com/cgu.html",
            "default_page_count": 20,
          }
        }
      end
    end
  end
end
