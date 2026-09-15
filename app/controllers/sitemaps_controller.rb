class SitemapsController < ApplicationController
  def show
    @pages = Page.published.ordered
    expires_in 1.hour, public: true
    render formats: :xml
  end
end
