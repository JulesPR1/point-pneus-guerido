require "test_helper"

class AdminPagesTest < ActionDispatch::IntegrationTest
  setup do
    site_setting
    sign_in create_admin
    @page = create_page(title: "Géométrie 3D", slug: "geometrie-3d")
  end

  test "lists the pages" do
    get admin_pages_path
    assert_response :success
    assert_select "td", /Géométrie 3D/
  end

  test "creates a page" do
    assert_difference "Page.count", 1 do
      post admin_pages_path, params: { page: { title: "Climatisation", status: "published" } }
    end

    created = Page.order(:id).last
    assert_equal "climatisation", created.slug
    assert_redirected_to admin_page_path(created)
  end

  test "refuses an invalid page and shows the errors" do
    assert_no_difference "Page.count" do
      post admin_pages_path, params: { page: { title: "" } }
    end

    assert_response :unprocessable_entity
    assert_select ".error-summary"
  end

  test "updates a page" do
    patch admin_page_path(@page), params: { page: { title: "Géométrie et parallélisme", seo_title: "Géométrie 3D à Cabestany" } }

    assert_redirected_to admin_page_path(@page)
    assert_equal "Géométrie et parallélisme", @page.reload.title
    assert_equal "Géométrie 3D à Cabestany", @page.seo_title
  end

  test "publishes and unpublishes" do
    draft = create_page(title: "Brouillon", slug: "brouillon", status: :draft)

    patch publish_admin_page_path(draft)
    assert draft.reload.published?

    patch unpublish_admin_page_path(draft)
    assert draft.reload.draft?
  end

  test "the home page cannot be unpublished nor destroyed" do
    home = create_page(title: "Accueil", slug: "accueil", home: true)

    patch unpublish_admin_page_path(home)
    assert home.reload.published?

    assert_no_difference "Page.count" do
      delete admin_page_path(home)
    end
  end

  test "destroys a page" do
    assert_difference "Page.count", -1 do
      delete admin_page_path(@page)
    end
    assert_redirected_to admin_pages_path
  end

  test "the dashboard reports the content and request counts" do
    create_section(@page)
    FormSubmission.create!(form_type: "contact",
                           payload: { "nom" => "X", "email" => "x@example.com",
                                      "sujet" => "Autre demande", "message" => "Bonjour" })

    get admin_root_path
    assert_response :success
    assert_select ".stat-card", minimum: 6
    assert_match "Demandes à traiter", response.body
  end
end
