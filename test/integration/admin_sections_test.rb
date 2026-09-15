require "test_helper"

class AdminSectionsTest < ActionDispatch::IntegrationTest
  setup do
    site_setting
    sign_in create_admin
    @page = create_page(title: "Accueil", slug: "accueil", home: true)
  end

  test "offers every registered section type" do
    get admin_page_path(@page)
    assert_response :success
    assert_select ".kind-card", count: SectionKind::ALL.size
  end

  test "the new-section form is built from the type definition" do
    get new_admin_page_section_path(@page, kind: "pricing")
    assert_response :success
    assert_select "input[name='section[heading]']"
    assert_select "textarea[name='section[body]']"
    assert_select "select[name='section[settings][tone]']"
  end

  test "the item form of a service grid offers the icon library" do
    section = create_section(@page, kind: "service_grid")
    get new_admin_section_section_item_path(section)

    assert_response :success
    assert_select "input[type=hidden][name='section_item[icon]']"
    assert_select ".icon-option", count: Icon::NAMES.size
  end

  test "the item list shows the icon of each service" do
    section = create_section(@page, kind: "service_grid")
    section.items.create!(title: "Recharge climatisation", icon: "thermometer-snowflake")
    get edit_admin_section_path(section)

    assert_select ".section-row .section-row__icon svg"
  end

  test "the item form of a section without icons does not offer the picker" do
    section = create_section(@page, kind: "pricing")
    get new_admin_section_section_item_path(section)

    assert_response :success
    assert_select ".icon-picker", count: 0
  end

  test "saves the icon picked in the back-office" do
    section = create_section(@page, kind: "service_grid")
    post admin_section_section_items_path(section), params: {
      section_item: { title: "Recharge climatisation", icon: "thermometer-snowflake" }
    }

    assert_equal "thermometer-snowflake", section.items.reload.last.icon
  end

  test "refuses an icon that is not in the library" do
    section = create_section(@page, kind: "service_grid")

    assert_no_difference "SectionItem.count" do
      post admin_section_section_items_path(section), params: {
        section_item: { title: "Freins", icon: "logo-maison" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "an unknown type is refused" do
    get new_admin_page_section_path(@page, kind: "carrousel_3d")
    assert_redirected_to admin_page_path(@page)
  end

  test "creates a section" do
    assert_difference "Section.count", 1 do
      post admin_page_sections_path(@page), params: {
        section: { kind: "checklist", heading: "Nos engagements", active: "1" }
      }
    end

    section = Section.order(:id).last
    assert_equal "checklist", section.kind
    assert_redirected_to edit_admin_section_path(section)
  end

  test "updates a section and keeps only declared settings" do
    section = create_section(@page, kind: "service_grid")

    patch admin_section_path(section), params: {
      section: { kind: "service_grid", heading: "Nos services",
                 settings: { columns: "4", tone: "dark", danger: "<script>" } }
    }

    section.reload
    assert_equal "Nos services", section.heading
    assert_equal({ "columns" => "4", "tone" => "dark" }, section.settings)
  end

  test "a setting value outside the declared options is dropped" do
    section = create_section(@page, kind: "service_grid")
    patch admin_section_path(section), params: { section: { kind: "service_grid", settings: { columns: "99" } } }

    assert_equal "3", section.reload.setting(:columns)
  end

  test "a free-text setting is stored, capped and cleared when emptied" do
    section = create_section(@page, kind: "google_reviews")

    patch admin_section_path(section),
          params: { section: { kind: "google_reviews", settings: { rating: " 4,6 ", reviews_count: "a" * 400 } } }
    assert_equal "4,6", section.reload.setting(:rating)
    assert_equal 300, section.setting(:reviews_count).length

    patch admin_section_path(section), params: { section: { kind: "google_reviews", settings: { rating: "" } } }
    assert_nil section.reload.setting(:rating)
  end

  test "a javascript: URL typed into a *_url setting is dropped" do
    section = create_section(@page, kind: "google_reviews")
    patch admin_section_path(section),
          params: { section: { kind: "google_reviews", settings: { profile_url: "javascript:alert(1)" } } }

    assert_nil section.reload.setting(:profile_url)
  end

  test "toggles a section on and off" do
    section = create_section(@page)

    patch toggle_admin_section_path(section)
    assert_not section.reload.active?

    patch toggle_admin_section_path(section)
    assert section.reload.active?
  end

  test "moves a section up and down" do
    first  = create_section(@page, heading: "A")
    second = create_section(@page, heading: "B")

    patch move_down_admin_section_path(first)
    assert_equal [ "B", "A" ], @page.sections.ordered.reload.map(&:heading)

    patch move_up_admin_section_path(first)
    assert_equal [ "A", "B" ], @page.sections.ordered.reload.map(&:heading)
    assert_operator first.reload.position, :<, second.reload.position
  end

  test "drag and drop reordering persists the new order" do
    a = create_section(@page, heading: "A")
    b = create_section(@page, heading: "B")
    c = create_section(@page, heading: "C")

    patch reorder_admin_page_sections_path(@page), params: { ordered_ids: [ c.id, b.id, a.id ] }
    assert_response :no_content
    assert_equal [ "C", "B", "A" ], @page.sections.ordered.reload.map(&:heading)
  end

  test "destroys a section" do
    section = create_section(@page)

    assert_difference "Section.count", -1 do
      delete admin_section_path(section)
    end
    assert_redirected_to admin_page_path(@page)
  end

  test "manages the items of a section" do
    section = create_section(@page, kind: "pricing")

    assert_difference "SectionItem.count", 1 do
      post admin_section_section_items_path(section), params: {
        section_item: { title: "Parallélisme avant", value: "65 €" }
      }
    end

    item = SectionItem.order(:id).last
    patch admin_section_item_path(item), params: { section_item: { value: "70 €" } }
    assert_equal "70 €", item.reload.value

    assert_difference "SectionItem.count", -1 do
      delete admin_section_item_path(item)
    end
  end

  test "reorders the items of a section" do
    section = create_section(@page, kind: "pricing")
    a = section.items.create!(title: "A")
    b = section.items.create!(title: "B")

    patch reorder_admin_section_section_items_path(section), params: { ordered_ids: [ b.id, a.id ] }
    assert_equal [ "B", "A" ], section.items.ordered.reload.map(&:title)
  end

  test "an unsafe link on an item is refused" do
    section = create_section(@page, kind: "service_grid")

    assert_no_difference "SectionItem.count" do
      post admin_section_section_items_path(section), params: {
        section_item: { title: "Piège", link_url: "javascript:alert(1)" }
      }
    end
    assert_response :unprocessable_entity
  end
end
