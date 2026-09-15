class AddMapAutoloadToSiteSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :site_settings, :map_autoload, :boolean, default: true, null: false
  end
end
