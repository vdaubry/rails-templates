module Presenters
  class ApplicationPresenter
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Context
    delegate :url_helpers, to: 'Rails.application.routes' #ex: url_helpers.path(...)
  end
end