require "test_helper"

class PublicSiteTest < ActionDispatch::IntegrationTest
  setup do
    site_setting
    @home = create_page(title: "Accueil", slug: "accueil", home: true)
    create_section(@home, kind: "hero", heading: "Pneus et *mécanique*", body: "Bienvenue.")
  end

  test "the home page renders at the root" do
    get root_path
    assert_response :success
    assert_select "h1", /Pneus et/
  end

  test "the hero accent word is emphasised, not printed as asterisks" do
    get root_path
    assert_select "h1 em", "mécanique"
    assert_no_match(/\*mécanique\*/, response.body)
  end

  test "the hero practical details are shown on the home page only" do
    interior = create_page(title: "Géométrie 3D", slug: "geometrie-3d")
    create_section(interior, kind: "hero", heading: "Parallélisme")

    get root_path
    assert_select ".hero__meta", 1

    get page_path("geometrie-3d")
    assert_select ".hero__meta", 0
  end

  test "a link with no label falls back to the item title, never to \"Découvrir\"" do
    page = create_page(title: "Entretiens", slug: "entretiens")
    section = create_section(page, kind: "service_grid", heading: "Nos prestations")
    section.items.create!(title: "Rénovation de phares", link_url: "/renovation-phares")
    cards = create_section(page, kind: "cards", heading: "Le garage")
    cards.items.create!(title: "Les pièces détachées", link_url: "/nos-pieces-detachees")

    get page_path("entretiens")
    assert_select "a.tile__link", text: "Rénovation de phares"
    assert_select "a.tile__link", text: "Les pièces détachées"
    assert_select "a.tile__link", text: /Découvrir|En savoir plus/, count: 0
  end

  test "a public form promises no delay the site cannot keep" do
    create_section(@home, kind: "form", heading: "Nous écrire",
                   settings: { "form_type" => "contact" })

    get root_path
    assert_select ".form-actions .form-required-note" do |notes|
      assert_no_match(/48 h|sous \d+ ?h|délai/i, notes.first.text)
      assert_match(/04 68 50 50 68/, notes.first.text)
    end
  end

  test "the legal notices live in one dialog, opened from the footer" do
    SiteSetting.instance.update!(legal_notice: "## Éditeur du site\n\nSARL au capital de 7 622,45 €.")
    other = create_page(title: "Devis pneus", slug: "devis-pneus")
    create_section(other, heading: "Formulaire")

    get root_path
    assert_select ".site-footer__legal a[href='#mentions-legales']", text: "Mentions légales"
    assert_select "dialog#mentions-legales[aria-labelledby=?]", "mentions-legales-titre"
    assert_select "dialog#mentions-legales h3", "Éditeur du site"

    # Une seule fois dans le site : la boîte du pied de page, et rien d'autre.
    get page_path("devis-pneus")
    assert_equal 1, response.body.scan("SARL au capital de 7 622,45 €.").size
  end

  test "no footer legal link when the notices have not been written" do
    SiteSetting.instance.update!(legal_notice: nil)

    get root_path
    assert_select "dialog#mentions-legales", 0
    assert_select ".site-footer__legal a", 0
  end

  test "the contact panel puts the form beside the practical details" do
    SiteSetting.instance.update!(opening_hours: "Lundi – vendredi|8h – 18h30\nSamedi|Fermé")
    page = create_page(title: "Contact", slug: "contact")
    create_section(page, kind: "contact_panel", heading: "Nous écrire",
                   subheading: "Écrivez-nous.", body: nil,
                   settings: { "form_type" => "contact" })

    get page_path("contact")
    assert_response :success
    assert_select ".contact-panel__info .contact-block", 2
    assert_select ".contact-panel__info .hours-table"
    assert_select ".contact-panel__form form"
    # Le chapô est rendu une fois, au-dessus des deux colonnes.
    assert_equal 1, response.body.scan("Écrivez-nous.").size
  end

  test "an interior page is served from its slug" do
    page = create_page(title: "Géométrie 3D", slug: "geometrie-3d")
    create_section(page, heading: "Parallélisme")

    get page_path("geometrie-3d")
    assert_response :success
    assert_select "h1", "Parallélisme"
  end

  test "a draft page is a 404 for a visitor" do
    create_page(title: "Brouillon", slug: "brouillon", status: :draft)

    get page_path("brouillon")
    assert_response :not_found
  end

  test "an unknown slug is a 404" do
    get page_path("nimporte-quoi")
    assert_response :not_found
  end

  test "sections render in their configured order" do
    page = create_page(title: "Ordre", slug: "ordre")
    first  = create_section(page, heading: "Premier")
    second = create_section(page, heading: "Deuxieme")

    get page_path("ordre")
    assert_operator response.body.index("Premier"), :<, response.body.index("Deuxieme")

    first.move_down!
    get page_path("ordre")
    assert_operator response.body.index("Deuxieme"), :<, response.body.index("Premier")
    assert_equal [ second, first ], page.sections.ordered.reload.to_a
  end

  test "a disabled section is not rendered" do
    page = create_page(title: "Masquage", slug: "masquage")
    create_section(page, heading: "Visible")
    create_section(page, heading: "Invisible", active: false)

    get page_path("masquage")
    assert_match "Visible", response.body
    assert_no_match(/Invisible/, response.body)
  end

  test "only one h1 is emitted per page" do
    page = create_page(title: "Titres", slug: "titres")
    create_section(page, kind: "hero", heading: "Premier titre")
    create_section(page, heading: "Deuxième titre")

    get page_path("titres")
    assert_select "h1", count: 1
    assert_select "h2", /Deuxième titre/
  end

  test "item titles stay one level below the section heading" do
    page = create_page(title: "Services", slug: "services")
    section = create_section(page, kind: "service_grid", heading: "Nos services")
    section.items.create!(title: "Centre de montage")

    get page_path("services")
    assert_select "h1", "Nos services"
    assert_select "h2", "Centre de montage"
    assert_select "h3", count: 0
  end

  test "a brand shows its logo when one is attached, its name otherwise" do
    page = create_page(title: "Marques", slug: "marques")
    section = create_section(page, kind: "brands", heading: "Nos marques")
    section.items.create!(title: "Michelin").image.attach(image_fixture)
    section.items.create!(title: "Pirelli")

    get page_path("marques")
    assert_select ".brands li.brands__logo img[alt=?]", "Michelin"
    assert_select ".brands li:not(.brands__logo)", "Pirelli"
  end

  test "the google reviews section shows the score, the count and each quote" do
    page = create_page(title: "Avis", slug: "avis")
    section = create_section(page, kind: "google_reviews", heading: "Ce que disent nos clients", body: nil,
                             settings: { "rating" => "4,6", "reviews_count" => "1312",
                                         "profile_url" => "https://www.google.com/maps/place/Point+Pneus" })
    section.items.create!(title: "Jean", subtitle: "mars 2026", value: "5", body: "Équipe au top.")

    get page_path("avis")
    assert_select ".reviews-summary__value", /4,6/
    assert_select ".reviews-summary__count", /1 312/
    assert_select ".reviews-summary__link[href=?]", "https://www.google.com/maps/place/Point+Pneus"
    assert_select ".review__author", "Jean"
    assert_select ".review__body p", /Équipe au top/
    assert_select ".review .stars[aria-label=?]", "5 étoiles sur 5"
  end

  test "the google reviews section shows only the number of quotes asked for" do
    page = create_page(title: "Avis", slug: "avis")
    section = create_section(page, kind: "google_reviews", heading: "Nos avis", body: nil,
                             settings: { "visible" => "3" })
    5.times { |i| section.items.create!(title: "Client #{i}", value: "5", body: "Avis #{i}") }

    get page_path("avis")
    assert_select ".review", count: 3

    section.update!(settings: { "visible" => "all" })
    get page_path("avis")
    assert_select ".review", count: 5
  end

  test "the google reviews section renders without a score or any quote" do
    page = create_page(title: "Avis", slug: "avis")
    create_section(page, kind: "google_reviews", heading: "Nos avis", body: nil,
                   settings: { "profile_url" => "https://www.google.com/maps/place/Point+Pneus" })

    get page_path("avis")
    assert_response :success
    assert_select ".reviews-summary__value", count: 0
    assert_select ".review", count: 0
    assert_select ".reviews-summary__link"
  end

  test "the footer map is in the page when the direct display is on" do
    SiteSetting.instance.update!(map_embed_url: "https://www.openstreetmap.org/export/embed.html?bbox=1",
                                 map_autoload: true)

    get root_path
    assert_select ".site-footer .map-frame iframe[src=?]", "https://www.openstreetmap.org/export/embed.html?bbox=1"
    assert_select ".site-footer .map-placeholder", count: 0
    assert_select ".site-footer .map-frame[data-map-src-value]", count: 0
  end

  test "the footer offers the map without calling the provider on load when the direct display is off" do
    SiteSetting.instance.update!(map_embed_url: "https://www.google.com/maps/embed?pb=abc",
                                 map_link_url: "https://www.google.com/maps/dir/?api=1&destination=Cabestany",
                                 map_autoload: false)

    get root_path
    assert_select ".site-footer .map-frame[data-map-src-value=?]", "https://www.google.com/maps/embed?pb=abc"
    assert_select ".site-footer .map-placeholder", /Google Maps/
    assert_select ".site-footer iframe", count: 0
  end

  test "the footer map column disappears when no embed url is set" do
    SiteSetting.instance.update!(map_embed_url: "")

    get root_path
    assert_select ".site-footer .map-frame", count: 0
  end

  test "seo tags come from the page" do
    create_page(title: "Contact", slug: "contact", seo_title: "Nous joindre",
                meta_description: "Adresse et horaires du garage.")

    get page_path("contact")
    assert_select "title", /Nous joindre/
    assert_select "meta[name=description][content=?]", "Adresse et horaires du garage."
    assert_select "link[rel=canonical][href*=?]", "/contact"
  end

  test "published pages appear in the navigation, drafts do not" do
    create_page(title: "Vente pneus", slug: "vente-pneus", position: 1)
    create_page(title: "Secret", slug: "secret", status: :draft, position: 2)

    get root_path
    assert_select "nav a", /Vente pneus/
    assert_no_match(/Secret/, response.body)
  end

  test "the sitemap lists published pages only" do
    create_page(title: "Contact", slug: "contact")
    create_page(title: "Brouillon", slug: "brouillon", status: :draft)

    get sitemap_path
    assert_response :success
    assert_match "/contact", response.body
    assert_no_match(/brouillon/, response.body)
  end

  test "backoffice-authored text is escaped, never injected as markup" do
    page = create_page(title: "Injection", slug: "injection")
    create_section(page, heading: "Titre", body: "<script>alert('xss')</script>")

    get page_path("injection")
    assert_no_match(/<script>alert/, response.body)
    assert_match "&lt;script&gt;", response.body
  end

  test "a signed-in administrator can preview a draft" do
    admin = create_admin
    create_page(title: "Brouillon", slug: "apercu", status: :draft)
                .then { |p| create_section(p, heading: "Contenu en préparation") }

    sign_in admin
    get page_path("apercu")
    assert_response :success
    assert_match "Contenu en préparation", response.body
  end
end
