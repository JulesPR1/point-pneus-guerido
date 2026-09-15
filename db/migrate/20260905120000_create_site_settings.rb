class CreateSiteSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      t.string  :company_name,    null: false, default: ""
      t.string  :tagline,         null: false, default: ""
      t.string  :phone,           null: false, default: ""
      t.string  :email,           null: false, default: ""
      t.string  :address_line,    null: false, default: ""
      t.string  :postal_code,     null: false, default: ""
      t.string  :city,            null: false, default: ""
      t.text    :opening_hours                          # one "Jour|Horaire" pair per line
      t.string  :map_embed_url
      t.string  :map_link_url
      t.text    :legal_notice
      t.string  :footer_credit
      t.string  :default_seo_title
      t.text    :default_meta_description
      t.timestamps
    end
  end
end
