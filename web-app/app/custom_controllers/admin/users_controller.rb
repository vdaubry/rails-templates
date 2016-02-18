module Admin
  class UsersController < Admin::ApplicationController
    # def index
    #   search_term = params[:search].to_s.strip
    #   resources = Administrate::Search.new(resource_resolver, search_term).run
    #   resources = params[:order].present? ? order.apply(resources) : resources.order("event_time DESC")
    #   resources = resources.includes(:team1, :team2).page(params[:page]).per(records_per_page)
    #   page = Administrate::Page::Collection.new(dashboard, order: order)

    #   render locals: {
    #       resources: resources,
    #       search_term: search_term,
    #       page: page,
    #   }
    # end
    
    # def create
    #   resource = resource_class.new(resource_params)
    #   resource.save
    #   flash[:notice] = translate_with_resource("create.success")
    #   redirect_to edit_admin_question_path(resource.question)
    # end

    # def destroy
    #   question = requested_resource.question
    #   requested_resource.destroy
    #   flash[:notice] = translate_with_resource("destroy.success")
    #   redirect_to edit_admin_question_path(question)
    # end
    
    def permitted_attributes
      super + [:password]
    end
  end
end
