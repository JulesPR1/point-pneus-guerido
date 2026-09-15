class CreateSections < ActiveRecord::Migration[8.1]
  def change
    create_table :sections do |t|
      t.references :page,     null: false, foreign_key: true
      t.string     :kind,     null: false
      t.integer    :position, null: false, default: 0
      t.boolean    :active,   null: false, default: true
      t.string     :eyebrow
      t.string     :heading
      t.string     :subheading
      t.text       :body
      t.json       :settings
      t.timestamps
    end

    add_index :sections, [ :page_id, :position ]
  end
end
