require "application_system_test_case"

class PublicNavigationTest < ApplicationSystemTestCase
  setup do
    # The browser is shared between tests, so start each one at desktop size.
    resize_to_desktop
    site_setting
    @home = create_page(title: "Accueil", slug: "accueil", home: true)
    create_section(@home, kind: "hero", heading: "Pneus et *mécanique*")
    create_page(title: "Géométrie 3D", slug: "geometrie-3d", position: 1)
  end

  test "the footer map iframe appears only once the visitor asks for it" do
    SiteSetting.instance.update!(map_embed_url: "https://www.google.com/maps/embed?pb=abc")
    visit root_path

    assert_no_selector ".site-footer .map-frame iframe"
    find(".site-footer .map-frame button").click
    assert_selector ".site-footer .map-frame iframe"
    assert_no_selector ".site-footer .map-placeholder"
  end

  test "a form result shows up as a toast the visitor can dismiss" do
    create_section(@home, kind: "form", heading: "Nous écrire",
                   settings: { "form_type" => "contact" })
    visit root_path

    fill_in "Nom", with: "Marie Dupont"
    fill_in "E-mail", with: "marie@example.com"
    select "Autre demande", from: "Sujet"
    fill_in "Votre message", with: "Bonjour, avez-vous du 205/55 R16 ?"
    click_on "Envoyer ma demande"

    toast = find(".toast--notice")
    assert_match "bien enregistré", toast.text
    # The card floats: it must not have pushed the page content down.
    assert_equal "fixed", find(".toaster").style("position")["position"]

    toast.find(".toast__close").click
    assert_no_selector ".toast"
  end

  test "the desktop menu shows the links inline" do
    visit root_path
    assert_selector "nav[aria-label='Navigation principale'] a", text: "Géométrie 3D"
  end

  test "the mobile drawer opens, navigates and closes" do
    resize_to_mobile
    visit root_path

    assert_no_selector "#menu-mobile a", visible: true
    find(".burger").click
    assert_selector "#menu-mobile a", text: "Géométrie 3D", visible: true

    find("#menu-mobile").click_link "Géométrie 3D"
    assert_current_path page_path("geometrie-3d")
  end

  test "the drawer closes on Escape" do
    resize_to_mobile
    visit root_path

    find(".burger").click
    assert_selector "#menu-mobile", visible: true

    find("body").send_keys :escape
    assert_no_selector "#menu-mobile a", visible: true
  end

  test "the sticky call bar is only shown on small screens" do
    resize_to_mobile
    visit root_path
    assert_selector ".mobile-actions a", text: /appeler/i, visible: true

    resize_to_desktop
    assert_no_selector ".mobile-actions a", text: /appeler/i, visible: true
  end

  test "the page does not scroll sideways on a phone" do
    resize_to_mobile
    visit root_path

    overflow = page.evaluate_script("document.documentElement.scrollWidth - document.documentElement.clientWidth")
    assert_operator overflow, :<=, 0, "la page déborde horizontalement de #{overflow}px"
  end

  private
    def resize_to_mobile  = page.driver.browser.manage.window.resize_to(390, 844)
    def resize_to_desktop = page.driver.browser.manage.window.resize_to(1400, 1000)
end
