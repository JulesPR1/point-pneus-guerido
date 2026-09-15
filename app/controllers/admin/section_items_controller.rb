module Admin
  class SectionItemsController < BaseController
    before_action :set_section, only: %i[new create reorder]
    before_action :set_item,    only: %i[edit update destroy move_up move_down]

    def new
      @item = @section.items.new
    end

    def create
      @item = @section.items.new(item_params)

      if @item.save
        redirect_to edit_admin_section_path(@section), notice: "#{@section.definition.item.label} ajouté."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @item.update(item_params)
        redirect_to edit_admin_section_path(@item.section), notice: "Élément enregistré."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      section = @item.section
      @item.destroy
      redirect_to edit_admin_section_path(section), notice: "Élément supprimé.", status: :see_other
    end

    def move_up
      @item.move_up!
      redirect_back_or_to edit_admin_section_path(@item.section)
    end

    def move_down
      @item.move_down!
      redirect_back_or_to edit_admin_section_path(@item.section)
    end

    def reorder
      SectionItem.reposition!(@section.items, Array(params[:ordered_ids]))
      head :no_content
    end

    private
      def set_section = @section = Section.find(params[:section_id])
      def set_item    = @item = SectionItem.find(params[:id])

      def item_params
        attrs = params.expect(section_item: [ :title, :subtitle, :body, :value, :icon,
                                              :link_url, :link_label, :image, :remove_image ])
        @item.image.purge if attrs.delete(:remove_image) == "1" && @item&.image&.attached?
        attrs
      end
  end
end
