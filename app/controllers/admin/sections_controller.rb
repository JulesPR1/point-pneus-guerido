module Admin
  class SectionsController < BaseController
    before_action :set_page,    only: %i[new create reorder]
    before_action :set_section, only: %i[edit update destroy move_up move_down toggle]

    def new
      @section = @page.sections.new(kind: params[:kind].presence || "rich_text")
      @definition = @section.definition
      redirect_to admin_page_path(@page), alert: "Type de section inconnu." if @definition.nil?
    end

    def create
      @section = @page.sections.new(section_params)
      @definition = @section.definition

      if @section.save
        redirect_to edit_admin_section_path(@section), notice: "Section ajoutée."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @definition = @section.definition
    end

    def update
      @definition = @section.definition

      if @section.update(section_params)
        redirect_to edit_admin_section_path(@section), notice: "Section enregistrée."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      page = @section.page
      @section.destroy
      redirect_to admin_page_path(page), notice: "Section supprimée.", status: :see_other
    end

    def move_up
      @section.move_up!
      redirect_back_or_to admin_page_path(@section.page)
    end

    def move_down
      @section.move_down!
      redirect_back_or_to admin_page_path(@section.page)
    end

    def toggle
      @section.toggle_active!
      redirect_back_or_to admin_page_path(@section.page),
                          notice: @section.active? ? "Section activée." : "Section désactivée."
    end

    def reorder
      Section.reposition!(@page.sections, Array(params[:ordered_ids]))
      head :no_content
    end

    private
      def set_page    = @page = Page.locate(params[:page_id])
      def set_section = @section = Section.includes(:items).find(params[:id])

      def section_params
        attrs = params.expect(section: [ :kind, :active, :eyebrow, :heading, :subheading, :body,
                                         :image, :remove_image, images: [], settings: {} ])
        purge_requested_attachments(attrs)
        attrs[:settings] = permitted_settings(attrs[:settings], attrs[:kind] || @section&.kind)
        attrs
      end

      def purge_requested_attachments(attrs)
        @section.image.purge if attrs.delete(:remove_image) == "1" && @section&.image&.attached?

        Array(params[:remove_image_ids]).each do |signed_id|
          @section&.images&.find { |img| img.signed_id == signed_id }&.purge
        end
      end

      # Only the settings the section type declares are stored. A setting with a
      # fixed list of options must hold one of them; a free-text setting is capped
      # in length, and one named *_url has to pass the same check as an item link.
      def permitted_settings(raw, kind)
        definition = SectionKind.find(kind)
        return @section&.settings if definition.nil? || raw.blank?

        definition.settings.each_with_object({}) do |setting, out|
          value = raw[setting.name].to_s.strip
          next if value.blank?

          if setting.options.present?
            next unless setting.options.include?(value)
          else
            value = value.truncate(300)
            next if setting.name.end_with?("_url") && !SafeUrl.safe?(value)
          end

          out[setting.name] = value
        end
      end
  end
end
