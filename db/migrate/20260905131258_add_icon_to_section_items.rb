class AddIconToSectionItems < ActiveRecord::Migration[8.1]
  def change
    add_column :section_items, :icon, :string
  end
end
