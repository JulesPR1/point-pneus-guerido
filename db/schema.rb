# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_07_094500) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_admin_users_on_email_address", unique: true
  end

  create_table "form_submissions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "admin_notes"
    t.string "contact_email"
    t.string "contact_name"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.string "form_type", null: false
    t.string "ip_address"
    t.json "payload", null: false
    t.string "status", default: "new", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_form_submissions_on_created_at"
    t.index ["form_type", "status"], name: "index_form_submissions_on_form_type_and_status"
  end

  create_table "media_items", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "pages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "home", default: false, null: false
    t.text "meta_description"
    t.string "nav_label"
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "published_at"
    t.string "seo_title"
    t.boolean "show_in_nav", default: true, null: false
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_pages_on_parent_id"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
    t.index ["status", "position"], name: "index_pages_on_status_and_position"
  end

  create_table "section_items", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "link_label"
    t.string "link_url"
    t.integer "position", default: 0, null: false
    t.bigint "section_id", null: false
    t.string "subtitle"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["section_id", "position"], name: "index_section_items_on_section_id_and_position"
    t.index ["section_id"], name: "index_section_items_on_section_id"
  end

  create_table "sections", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.string "eyebrow"
    t.string "heading"
    t.string "kind", null: false
    t.bigint "page_id", null: false
    t.integer "position", default: 0, null: false
    t.json "settings"
    t.string "subheading"
    t.datetime "updated_at", null: false
    t.index ["page_id", "position"], name: "index_sections_on_page_id_and_position"
    t.index ["page_id"], name: "index_sections_on_page_id"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["admin_user_id"], name: "index_sessions_on_admin_user_id"
  end

  create_table "site_settings", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address_line", default: "", null: false
    t.string "city", default: "", null: false
    t.string "company_name", default: "", null: false
    t.datetime "created_at", null: false
    t.text "default_meta_description"
    t.string "default_seo_title"
    t.string "email", default: "", null: false
    t.text "legal_notice"
    t.boolean "map_autoload", default: true, null: false
    t.text "map_embed_url"
    t.text "map_link_url"
    t.text "opening_hours"
    t.string "phone", default: "", null: false
    t.string "postal_code", default: "", null: false
    t.string "tagline", default: "", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "pages", "pages", column: "parent_id"
  add_foreign_key "section_items", "sections"
  add_foreign_key "sections", "pages"
  add_foreign_key "sessions", "admin_users"
end
