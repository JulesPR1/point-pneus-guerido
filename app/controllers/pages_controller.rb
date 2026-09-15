class PagesController < ApplicationController
  include Authentication
  allow_unauthenticated_access

  before_action :set_page

  def show
    # The page is touched by its sections and items, so its timestamp covers the
    # whole body; the navigation and the shared settings are added on top.
    return if preview?

    fresh_when etag: [ @page, Page.maximum(:updated_at), SiteSetting.instance ]
  end

  private
    def set_page
      @page = if params[:slug].present?
        page_scope.find_by!(slug: params[:slug])
      else
        page_scope.find_by!(home: true)
      end

      @sections = @page.sections.active.ordered.includes(
        { items: { image_attachment: :blob } },
        { image_attachment: :blob },
        { images_attachments: :blob }
      ).to_a
      @h1_section_id = Page.primary_heading_section(@sections)&.id
    rescue ActiveRecord::RecordNotFound
      render "errors/not_found", status: :not_found, layout: "application"
    end

    # Drafts are visible only to a signed-in administrator, for the backoffice preview.
    def page_scope = preview? ? Page.all : Page.published

    def preview? = authenticated?
end
