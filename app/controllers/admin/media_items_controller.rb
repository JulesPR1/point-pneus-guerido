module Admin
  class MediaItemsController < BaseController
    before_action :set_media_item, only: %i[edit update destroy]

    def index
      @pagination = Pagination.new(MediaItem.recent, page: params[:page], per_page: 24)
      @media_items = @pagination.records.with_attached_file
    end

    def new
      @media_item = MediaItem.new
    end

    def edit
    end

    def create
      files = Array(params.dig(:media_item, :files)).compact_blank
      return redirect_to(new_admin_media_item_path, alert: "Choisissez au moins une image.") if files.empty?

      created = files.filter_map do |file|
        item = MediaItem.new(title: params.dig(:media_item, :title).presence,
                             alt_text: params.dig(:media_item, :alt_text).presence)
        item.file.attach(file)
        item if item.save
      end

      if created.any?
        redirect_to admin_media_items_path, notice: "#{created.size} image(s) ajoutée(s)."
      else
        @media_item = MediaItem.new
        @media_item.errors.add(:file, "n'a pas pu être enregistrée (format ou taille non acceptés)")
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @media_item.update(media_item_params)
        redirect_to admin_media_items_path, notice: "Image mise à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @media_item.destroy
      redirect_to admin_media_items_path, notice: "Image supprimée.", status: :see_other
    end

    private
      def set_media_item = @media_item = MediaItem.find(params[:id])

      def media_item_params
        params.expect(media_item: [ :title, :alt_text, :file ])
      end
  end
end
