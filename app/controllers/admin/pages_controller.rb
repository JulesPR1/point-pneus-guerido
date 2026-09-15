module Admin
  class PagesController < BaseController
    before_action :set_page, only: %i[show edit update destroy publish unpublish]

    def index
      @pages = Page.ordered.includes(:parent).left_joins(:sections)
                   .select("pages.*, COUNT(sections.id) AS sections_count").group("pages.id")
    end

    def show
      @sections = @page.sections.ordered.includes(:items, { image_attachment: :blob })
    end

    def new
      @page = Page.new(status: :draft, show_in_nav: true)
    end

    def edit
    end

    def create
      @page = Page.new(page_params)

      if @page.save
        redirect_to admin_page_path(@page), notice: "Page créée. Ajoutez maintenant ses sections."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @page.update(page_params)
        redirect_to admin_page_path(@page), notice: "Page mise à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @page.home?
        redirect_to admin_pages_path, alert: "La page d'accueil ne peut pas être supprimée."
      else
        @page.destroy
        redirect_to admin_pages_path, notice: "Page supprimée.", status: :see_other
      end
    end

    def publish
      @page.publish!
      redirect_back_or_to admin_page_path(@page), notice: "Page publiée."
    end

    def unpublish
      if @page.home?
        redirect_back_or_to admin_page_path(@page), alert: "La page d'accueil doit rester publiée."
      else
        @page.unpublish!
        redirect_back_or_to admin_page_path(@page), notice: "Page dépubliée."
      end
    end

    private
      def set_page = @page = Page.locate(params[:id])

      def page_params
        attrs = params.expect(page: [ :title, :slug, :nav_label, :status, :position, :show_in_nav,
                                      :parent_id, :seo_title, :meta_description, :og_image, :remove_og_image ])
        @page.og_image.purge if attrs.delete(:remove_og_image) == "1" && @page&.og_image&.attached?
        attrs
      end
  end
end
