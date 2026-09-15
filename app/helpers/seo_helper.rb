module SeoHelper
  def document_title(page = @page)
    parts = [ page&.document_title, site_setting.default_seo_title.presence || site_setting.company_name ]
    parts.compact_blank.uniq.join(" — ")
  end

  def meta_description(page = @page)
    page&.meta_description.presence || site_setting.default_meta_description.presence
  end

  def canonical_url(page = @page)
    page.nil? ? request.original_url.split("?").first : URI.join(root_url, page.path).to_s
  end

  def og_image_url(page = @page)
    attachment = page&.og_image&.attached? ? page.og_image : site_setting.default_og_image
    return unless attachment&.attached?

    url_for(attachment.variant(:og))
  end

  # Minimal, factual structured data — only fields the client actually published.
  def local_business_json_ld
    setting = site_setting
    data = {
      "@context" => "https://schema.org",
      "@type" => "AutoRepair",
      "name" => setting.company_name,
      "telephone" => setting.phone.presence,
      "email" => setting.email.presence,
      "url" => root_url,
      "address" => {
        "@type" => "PostalAddress",
        "streetAddress" => setting.address_line.presence,
        "postalCode" => setting.postal_code.presence,
        "addressLocality" => setting.city.presence,
        "addressCountry" => "FR"
      }.compact_blank.presence
    }.compact_blank

    # json_escape turns <, > and & into \u sequences so a stray "</script>" in a
    # setting cannot break out of the tag.
    tag.script(type: "application/ld+json") { json_escape(data.to_json).html_safe } # rubocop:disable Rails/OutputSafety
  end
end
