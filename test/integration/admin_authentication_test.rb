require "test_helper"

class AdminAuthenticationTest < ActionDispatch::IntegrationTest
  setup { @admin = create_admin(email_address: "gerant@example.com") }

  test "every admin route redirects an anonymous visitor to the login form" do
    page = create_page(title: "Page")
    section = create_section(page)
    submission = FormSubmission.create!(form_type: "contact",
                                        payload: { "nom" => "X", "email" => "x@example.com",
                                                   "sujet" => "Autre demande", "message" => "Bonjour" })

    [
      admin_root_path, admin_pages_path, new_admin_page_path, admin_page_path(page),
      edit_admin_page_path(page), edit_admin_section_path(section),
      admin_media_items_path, new_admin_media_item_path,
      admin_form_submissions_path, admin_form_submission_path(submission),
      edit_admin_site_setting_path
    ].each do |path|
      get path
      assert_redirected_to new_admin_session_path, "#{path} devrait être protégé"
    end
  end

  test "write actions are protected too" do
    page = create_page(title: "Page")

    assert_no_difference "Page.count" do
      post admin_pages_path, params: { page: { title: "Injectée" } }
    end
    assert_redirected_to new_admin_session_path

    assert_no_difference "Page.count" do
      delete admin_page_path(page)
    end
  end

  test "signing in with the right password opens the dashboard" do
    sign_in @admin
    assert_redirected_to admin_root_url

    follow_redirect!
    assert_response :success
    assert_select "h1", "Tableau de bord"
  end

  test "a wrong password is refused" do
    post admin_session_path, params: { email_address: @admin.email_address, password: "mauvais" }
    assert_redirected_to new_admin_session_path

    get admin_root_path
    assert_redirected_to new_admin_session_path
  end

  test "an unknown email is refused" do
    post admin_session_path, params: { email_address: "personne@example.com", password: "motdepasse-long-1" }
    assert_redirected_to new_admin_session_path
  end

  test "signing out ends the session" do
    sign_in @admin
    delete admin_session_path
    assert_redirected_to new_admin_session_path

    get admin_pages_path
    assert_redirected_to new_admin_session_path
  end

  test "the visitor is sent back to the page they asked for" do
    page = create_page(title: "Page")
    get admin_page_path(page)
    sign_in @admin
    assert_redirected_to admin_page_url(page)
  end

  test "the login page is not indexable" do
    get new_admin_session_path
    assert_response :success
    assert_select "meta[name=robots][content*=noindex]", visible: false
  end
end
