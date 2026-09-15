require "test_helper"

class AdminMediaTest < ActionDispatch::IntegrationTest
  setup do
    site_setting
    sign_in create_admin
  end

  test "uploads several images at once" do
    assert_difference "MediaItem.count", 2 do
      post admin_media_items_path, params: {
        media_item: { alt_text: "Atelier", files: [ image_fixture, image_fixture ] }
      }
    end

    assert_redirected_to admin_media_items_path
    assert_equal "Atelier", MediaItem.last.alt_text
  end

  test "refuses an upload with no file" do
    assert_no_difference "MediaItem.count" do
      post admin_media_items_path, params: { media_item: { alt_text: "Rien" } }
    end
    assert_redirected_to new_admin_media_item_path
  end

  test "refuses a file that is not an image, whatever content type it claims" do
    script = Tempfile.new([ "payload", ".png" ]).tap { |f| f.write("#!/bin/sh\nrm -rf /\n"); f.rewind }
    upload = Rack::Test::UploadedFile.new(script.path, "image/png")

    assert_no_difference "MediaItem.count" do
      post admin_media_items_path, params: { media_item: { files: [ upload ] } }
    end
    assert_response :unprocessable_entity
  end

  test "lists, edits and deletes an image" do
    post admin_media_items_path, params: { media_item: { files: [ image_fixture ] } }
    media = MediaItem.last

    get admin_media_items_path
    assert_response :success
    assert_select ".media-card", 1

    patch admin_media_item_path(media), params: { media_item: { alt_text: "Vue du comptoir" } }
    assert_equal "Vue du comptoir", media.reload.alt_text

    assert_difference "MediaItem.count", -1 do
      delete admin_media_item_path(media)
    end
  end

  test "an image can be attached to a section and shown on the public page" do
    page = create_page(title: "Vente pneus", slug: "vente-pneus")
    section = create_section(page, kind: "text_image", heading: "Pneus")

    patch admin_section_path(section), params: {
      section: { kind: "text_image", heading: "Pneus", image: image_fixture }
    }
    assert section.reload.image.attached?

    delete admin_session_path
    get page_path("vente-pneus")
    assert_response :success
    assert_select "img"
  end
end

class AdminSiteSettingsTest < ActionDispatch::IntegrationTest
  setup do
    site_setting
    sign_in create_admin
  end

  test "a map url that is not http(s) is refused" do
    patch admin_site_setting_path, params: {
      site_setting: { company_name: "Point Pneus Guerido", phone: "04 68 50 50 68",
                      map_embed_url: "javascript:alert(1)" }
    }
    assert_response :unprocessable_entity
    assert_not_equal "javascript:alert(1)", SiteSetting.instance.reload.map_embed_url
  end

  test "updates the site details" do
    patch admin_site_setting_path, params: {
      site_setting: { company_name: "Point Pneus Guerido", phone: "04 68 50 50 68",
                      opening_hours: "Lundi – vendredi|8h – 12h / 14h – 18h30\nSamedi|Fermé" }
    }

    setting = SiteSetting.instance.reload
    assert_equal [ [ "Lundi – vendredi", "8h – 12h / 14h – 18h30" ], [ "Samedi", "Fermé" ] ], setting.hours
    assert_equal "tel:+33468505068", setting.phone_link
  end

  test "refuses to blank the phone number" do
    patch admin_site_setting_path, params: { site_setting: { company_name: "Point Pneus", phone: "" } }
    assert_response :unprocessable_entity
  end
end
