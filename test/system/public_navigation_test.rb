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

  # Réglage par défaut : la carte est dans la page. L'iframe Google dépose ses
  # cookies dès le chargement, ce qui suppose un bandeau de consentement — le
  # choix appartient au propriétaire du site, pas à ce test.
  test "the map is in the page when the site setting says so" do
    SiteSetting.instance.update!(map_embed_url: "https://www.google.com/maps/embed?pb=abc",
                                 map_autoload: true)
    visit root_path

    assert_selector ".site-footer .map-frame iframe"
    assert_no_selector ".site-footer .map-placeholder"
  end

  test "the map waits for a click when autoload is turned off" do
    SiteSetting.instance.update!(map_embed_url: "https://www.google.com/maps/embed?pb=abc",
                                 map_autoload: false)
    visit root_path

    assert_no_selector ".site-footer .map-frame iframe"
    find(".site-footer .map-frame button").click
    assert_selector ".site-footer .map-frame iframe"
    assert_no_selector ".site-footer .map-placeholder"
  end

  # Le lien d'itinéraire vivait dans le placeholder, que map_controller retire
  # en insérant l'iframe : il disparaissait au moment où le visiteur venait de
  # dire qu'il cherchait son chemin.
  test "the directions button survives loading the map" do
    SiteSetting.instance.update!(map_embed_url: "https://www.google.com/maps/embed?pb=abc",
                                 map_link_url: "https://www.google.com/maps/dir/?api=1&destination=Garage",
                                 map_autoload: false)
    create_section(@home, kind: "map", heading: "Plan d'accès")
    visit root_path

    within "main" do
      assert_selector "a.btn", text: "Ouvrir l'itinéraire"
      find(".map-frame button").click
      assert_selector ".map-frame iframe"
      assert_no_selector ".map-frame .map-placeholder"
      assert_selector "a.btn", text: "Ouvrir l'itinéraire"
    end
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

  test "the legal notices open in a dialog from the footer, and close again" do
    SiteSetting.instance.update!(legal_notice: "## Éditeur du site\n\nSARL au capital de 7 622,45 €.")
    visit root_path

    assert_no_text "SARL au capital"
    find(".site-footer__legal a", text: "Mentions légales").click

    dialog = find("dialog#mentions-legales")
    assert dialog.evaluate_script("this.open"), "la boîte de dialogue devrait être ouverte"
    assert_text "SARL au capital de 7 622,45 €."

    find("body").send_keys :escape
    assert_no_text "SARL au capital"
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

    assert_operator horizontal_overflow, :<=, 0,
                    "la page déborde horizontalement de #{horizontal_overflow}px"
  end

  # The kinds that carry the long strings — prices, brand names, quotes, part
  # lists — are the ones that push a phone screen sideways.
  test "a page loaded with every content-heavy section still fits a phone" do
    page_record = create_page(title: "Tout", slug: "tout", position: 2)

    grid = create_section(page_record, kind: "service_grid", heading: "Nos services",
                          settings: { "columns" => "3" })
    grid.items.create!(title: "Parallélisme / géométrie 3D", link_url: "/geometrie-3d",
                       link_label: "Voir les tarifs de géométrie",
                       body: "Parallélisme avant 65 €. Avant + arrière et carrossage 85 €, 100 € en 4x4 ou camionnette.")

    prices = create_section(page_record, kind: "pricing", heading: "Tarifs", body: nil)
    prices.items.create!(title: "Parallélisme avant + train arrière et carrossage", value: "85 €")

    brands = create_section(page_record, kind: "brands", heading: "Marques", body: nil)
    %w[Michelin Goodyear BFGoodrich].each { |name| brands.items.create!(title: name) }

    columns = create_section(page_record, kind: "list_columns", heading: "Pièces", body: nil)
    columns.items.create!(title: "Direction, suspension, train",
                          body: "Amortissement\nTriangle de suspension\nRoulement de roue")

    reviews = create_section(page_record, kind: "google_reviews", heading: "Avis", body: nil,
                             settings: { "columns" => "3", "visible" => "3" })
    reviews.items.create!(title: "Gwendoline Lamblin", subtitle: "août 2025", value: "5",
                          body: "Une prise en charge rapide et efficace. Je recommande vivement.")

    resize_to_mobile
    visit page_path("tout")

    assert_operator horizontal_overflow, :<=, 0,
                    "la page déborde horizontalement de #{horizontal_overflow}px"
  end

  private
    def horizontal_overflow
      page.evaluate_script("document.documentElement.scrollWidth - document.documentElement.clientWidth")
    end

    def resize_to_mobile  = page.driver.browser.manage.window.resize_to(390, 844)
    def resize_to_desktop = page.driver.browser.manage.window.resize_to(1400, 1000)
end
