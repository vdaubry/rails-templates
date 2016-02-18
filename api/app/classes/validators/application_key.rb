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
    
    def api_keys
      @api_keys ||= { 
        "unit_test" => {app_version: "unit_test"}
      }
    end
  end
end