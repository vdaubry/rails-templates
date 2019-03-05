module Validators
  class ApplicationKey
    def initialize(api_key:)
      @api_key = api_key
    end
    
    def authorised?
      api_keys[api_key].present?
    end
    
    private
    attr_reader :api_key
    
    #Generate with SecureRandom.hex(6)
    def api_keys
      @api_keys ||= { 
        "unit_test" => {platform: "test", app_version: "unit_test"},
        "ce70b3608cdb" => {platform: "ios", app_version: "1.0"},
      }
    end
  end
end