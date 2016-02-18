module Presenters
  class ApplicationPresenter
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Context
  end
end