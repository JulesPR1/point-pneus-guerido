require "application_system_test_case"

class AdminContentTest < ApplicationSystemTestCase
  setup do
    page.driver.browser.manage.window.resize_to(1400, 1000)
    site_setting
    @admin = create_admin(email_address: "gerant@example.com")
    @page = create_page(title: "Accueil", slug: "accueil", home: true)
  end

  test "an administrator signs in, reorders sections and sees the change on the site" do
    create_section(@page, kind: "rich_text", heading: "Premier bloc")
    create_section(@page, kind: "rich_text", heading: "Deuxième bloc")

    sign_in_as_admin
    visit admin_page_path(@page)

    within(first(".section-row")) { click_button "↓" }
    assert_selector ".section-row:first-child", text: "Deuxième bloc"
    assert_equal [ "Deuxième bloc", "Premier bloc" ], @page.sections.ordered.reload.map(&:heading)

    visit root_path
    assert_operator page.body.index("Deuxième bloc"), :<, page.body.index("Premier bloc")
  end

  test "hiding a section removes it from the public page" do
    create_section(@page, kind: "rich_text", heading: "Bloc à masquer")

    sign_in_as_admin
    visit admin_page_path(@page)
    click_button "Masquer"
    assert_text "Section désactivée"

    Capybara.reset_sessions!
    visit root_path
    assert_no_text "Bloc à masquer"
  end

  test "a new section is created from the type picker and shows up on the site" do
    sign_in_as_admin
    visit admin_page_path(@page)

    click_link "Liste d'arguments"
    fill_in "Titre", with: "Nos engagements"
    click_button "Créer la section"
    assert_text "Section ajoutée"

    click_link "Ajouter argument"
    fill_in "Texte", with: "Recyclage des pneus usagés"
    click_button "Ajouter"

    visit root_path
    assert_text "Nos engagements"
    assert_text "Recyclage des pneus usagés"
  end

  private
    def sign_in_as_admin
      visit new_admin_session_path
      fill_in "Adresse e-mail", with: @admin.email_address
      fill_in "Mot de passe", with: "motdepasse-long-1"
      click_button "Se connecter"
      assert_text "Tableau de bord"
    end
end
