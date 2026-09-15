class CreateMediaItems < ActiveRecord::Migration[8.1]
  def change
    create_table :media_items do |t|
      t.string :title
      t.string :alt_text
      t.timestamps
    end
  end
end
