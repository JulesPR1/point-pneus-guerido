class CreateSectionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :section_items do |t|
      t.references :section,  null: false, foreign_key: true
      t.integer    :position, null: false, default: 0
      t.string     :title
      t.string     :subtitle
      t.text       :body
      t.string     :value
      t.string     :link_url
      t.string     :link_label
      t.timestamps
    end

    add_index :section_items, [ :section_id, :position ]
  end
end
