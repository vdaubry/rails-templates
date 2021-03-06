module Validators
  class ApiRequestValidator
    def initialize(params:, headers:, env:)
      @params = params
      @headers = headers
      @env = env
    end

    def validate!
      return if Rails.env.test?

      raise Validators::UnauthorisedApiKeyError unless Validators::ApplicationKey.new(api_key: api_key).authorised?
    end

    private
    attr_reader :params, :headers, :env

    def api_key
      headers['X-API-Key'] || env['X-API-Key'] || env['HTTP_X_API_KEY']
    end
  end
end

class UnauthorisedApiKeyError < StandardError; end
end