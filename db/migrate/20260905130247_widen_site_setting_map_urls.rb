# Google Maps embed URLs run past 255 characters, so the two map columns move to text.
class WidenSiteSettingMapUrls < ActiveRecord::Migration[8.1]
  def up
    change_column :site_settings, :map_embed_url, :text
    change_column :site_settings, :map_link_url, :text
  end

  def down
    change_column :site_settings, :map_embed_url, :string
    change_column :site_settings, :map_link_url, :string
  end
end
