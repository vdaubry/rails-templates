module GenericHelper
  def parsed_response
    JSON.parse(response.body)
  end

  def error
    parsed_response.dig("result", "error")
  end

  def info
    parsed_response.dig("result", "info")
  end
end