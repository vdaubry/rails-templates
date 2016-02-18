module HeaderHelper
  def active_page_class(path)
    path_controller = Rails.application.routes.recognize_path(path)[:controller]
    controller.controller_name == path_controller ? "active" : ""
  end

  def menu_link(name, path)
    content_tag(:li, class: active_page_class(path)) do
      link_to name.capitalize, path
    end
  end
end