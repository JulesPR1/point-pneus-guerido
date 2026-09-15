class CreateFormSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :form_submissions do |t|
      t.string :form_type,     null: false
      t.string :status,        null: false, default: "new"
      t.json   :payload,       null: false
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.text   :admin_notes
      t.string :ip_address
      t.timestamps
    end

    add_index :form_submissions, [ :form_type, :status ]
    add_index :form_submissions, :created_at
  end
end
