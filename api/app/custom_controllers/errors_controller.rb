class ErrorsController < ActionController::API
  def not_found
    render json: {"error":{code: "RESSOURCE_NOT_FOUND", message: "The requested ressource (page or object) doesn't exist"}}, status: 404
  end

  def exception
    render json: {"error":{code: "EXCEPTION", message: "Internal Server Error"}}, status: 500
  end
end