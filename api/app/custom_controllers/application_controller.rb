class ApplicationController <  ActionController::API
  before_filter :check_rack_mini_profiler

  def check_rack_mini_profiler
    Rack::MiniProfiler.authorize_request if ENV["PROFILING"] == "true"
  end
end