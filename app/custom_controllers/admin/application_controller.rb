# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_filters.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_filter :authenticate_admin

    def authenticate_admin
      if current_admin.nil?
        flash[:alert] = "Please sign in with an admin account to access this page"
        return redirect_to new_session_path
      end
      
    end
    
    def current_admin
      @current_admin ||= User.where(id: session[:user_id], admin: true).first
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
