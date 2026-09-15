class RemoveFooterCreditFromSiteSettings < ActiveRecord::Migration[8.1]
  def change
    remove_column :site_settings, :footer_credit, :string
  end
end
