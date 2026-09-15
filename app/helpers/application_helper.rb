module ApplicationHelper
  def site_setting
    @site_setting ||= SiteSetting.instance
  end

  # Top-level published pages flagged for the menu, with their children preloaded.
  def nav_pages
    @nav_pages ||= Page.published.in_nav.top_level.ordered.includes(:children).reject(&:home?)
  end

  # Where the "Devis gratuit" buttons point. Falls back gracefully if the client
  # renames or unpublishes the quote page.
  def quote_page_path
    @quote_page_path ||= begin
      page = Page.published.where(slug: %w[devis-pneus-perpignan devis-pneus devis]).first ||
             Page.published.in_nav.where.not(home: true).ordered.first
      page ? page_path(page) : root_path
    end
  end

  # Named so the consent notice tells the visitor who actually receives the
  # request, whatever embed URL the backoffice holds.
  MAP_PROVIDERS = { "google" => "Google Maps", "openstreetmap" => "OpenStreetMap",
                    "mappy" => "Mappy", "bing" => "Bing Maps" }.freeze

  def map_provider_name
    host = URI.parse(site_setting.map_embed_url.to_s).host.to_s
    MAP_PROVIDERS.find { |needle, _| host.include?(needle) }&.last || "un service de cartographie"
  rescue URI::InvalidURIError
    "un service de cartographie"
  end

  # Visitor-supplied text: escaped, with line breaks preserved. Never
  # simple_format, which would let sanitised-but-real markup through.
  def escaped_multiline(text)
    safe_join(text.to_s.split(/\r?\n/), tag.br)
  end

  # Bumped whenever any page is edited, published or reordered — used as the
  # cache key of the shared header and footer fragments.
  def content_version = @content_version ||= Page.maximum(:updated_at)

  def flash_class(type)
    type.to_s == "notice" ? "flash flash--notice" : "flash flash--alert"
  end

  # Human labels for the section settings declared in SectionKind.
  SETTING_LABELS = {
    "image_side" => { "right" => "À droite", "left" => "À gauche" },
    "columns" => { "2" => "2 colonnes", "3" => "3 colonnes", "4" => "4 colonnes", "5" => "5 colonnes" },
    "tone" => { "dark" => "Sombre", "signal" => "Jaune", "paper" => "Clair" },
    "form_type" => { "devis_pneus" => "Devis pneus", "devis_mecanique" => "Devis mécanique", "contact" => "Contact" },
    "visible" => { "3" => "3 avis", "6" => "6 avis", "9" => "9 avis", "12" => "12 avis", "all" => "Tous les avis" }
  }.freeze

  def setting_options(setting)
    labels = SETTING_LABELS[setting.name] || {}
    Array(setting.options).map { |option| [ labels[option] || option, option ] }
  end

  def active_page?(page)
    page.home? ? current_page?(root_path) : current_page?(page_path(page))
  end
end
