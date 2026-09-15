class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.string     :title,            null: false
      t.string     :slug,             null: false
      t.string     :nav_label
      t.string     :status,           null: false, default: "draft"
      t.integer    :position,         null: false, default: 0
      t.boolean    :show_in_nav,      null: false, default: true
      t.boolean    :home,             null: false, default: false
      t.references :parent, foreign_key: { to_table: :pages }, null: true
      t.string     :seo_title
      t.text       :meta_description
      t.datetime   :published_at
      t.timestamps
    end

    add_index :pages, :slug, unique: true
    add_index :pages, [ :status, :position ]
  end
end
