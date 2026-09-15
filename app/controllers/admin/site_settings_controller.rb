module Admin
  class SiteSettingsController < BaseController
    before_action :set_site_setting

    def edit
    end

    def update
      if @site_setting.update(site_setting_params)
        redirect_to edit_admin_site_setting_path, notice: "Réglages enregistrés."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
      def set_site_setting = @site_setting = SiteSetting.instance

      def site_setting_params
        attrs = params.expect(site_setting: [ :company_name, :tagline, :phone, :email, :address_line,
                                              :postal_code, :city, :opening_hours, :map_embed_url,
                                              :map_link_url, :map_autoload, :legal_notice,
                                              :default_seo_title, :default_meta_description,
                                              :logo, :default_og_image ])
        attrs.delete(:logo) if attrs[:logo].blank?
        attrs.delete(:default_og_image) if attrs[:default_og_image].blank?
        attrs
      end
  end
end
