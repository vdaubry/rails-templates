class ErrorsController < ActionController::API
  def not_found
    render json: {"error":{code: "PAGE_NOT_FOUND", message: "The endpoint you called doesn't exist"}}, status: 404
  end

  def exception
    render json: {"error":{code: "EXCEPTION", message: "Internal Server Error"}}, status: 500
  end
end