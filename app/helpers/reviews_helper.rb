# Rendering of the Google reviews section: the star rows and the Google mark.
#
# Nothing here fetches anything — the reviews are copied into the CMS by hand,
# so the site never depends on an API key and never shows a review the garage
# has not read.
module ReviewsHelper
  MAX_STARS = 5

  STAR = '<path d="M12 2.2l3.02 6.12 6.76.98-4.89 4.77 1.15 6.73L12 17.63l-6.04 3.17 ' \
         '1.15-6.73L2.22 9.3l6.76-.98z"/>'

  # The four-colour Google "G", drawn rather than shipped as an image so it
  # stays sharp and costs no request. Reproduced from Google's own mark.
  GOOGLE_G = '<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 ' \
             '14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>' \
             '<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 ' \
             '5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>' \
             '<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.28-3.14.76-4.59l-7.98-6.19C.92 ' \
             '16.46 0 20.12 0 24c0 3.88.92 7.54 2.55 10.78l7.98-6.19z"/>' \
             '<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 ' \
             '2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>'

  # "4,6" and "4.6" are the same score to whoever is typing in the backoffice,
  # so both are accepted. Anything else returns nil and the caller renders nothing.
  def review_score(value)
    text = value.to_s.strip.tr(",", ".")
    return unless text.match?(/\A\d{1,2}(\.\d+)?\z/)

    score = text.to_f
    score.positive? && score <= MAX_STARS ? score : nil
  end

  # 5 → "5", 4.6 → "4,6"
  def review_score_label(value)
    score = review_score(value)
    return if score.nil?

    number_with_precision(score, precision: score == score.round ? 0 : 1, separator: ",")
  end

  # A whole number typed as "312" or "1 312" comes back as "312" / "1 312".
  def review_count_label(value)
    digits = value.to_s.gsub(/\D/, "")
    return if digits.blank?

    number_with_delimiter(digits.to_i, delimiter: " ")
  end

  # Five stars with the gold layer clipped to the score. Two identical layers
  # rather than a per-star gradient: no generated ids, so the same markup can
  # repeat as often as needed on one page.
  def stars_tag(value, class_name: nil)
    score = review_score(value)
    return if score.nil?

    layers = %w[stars__track stars__fill].map do |modifier|
      tag.span(safe_join(Array.new(MAX_STARS) { star_tag }), class: "stars__layer #{modifier}")
    end

    tag.span safe_join(layers), class: [ "stars", class_name ].compact.join(" "),
             style: "--stars: #{(score / MAX_STARS * 100).round(2)}%",
             role: "img", "aria-label": "#{review_score_label(value)} étoiles sur #{MAX_STARS}"
  end

  def google_logo_tag
    tag.svg GOOGLE_G.html_safe, # rubocop:disable Rails/OutputSafety -- static markup above
            class: "google-mark", viewBox: "0 0 48 48",
            "aria-hidden": "true", focusable: "false"
  end

  # First letter of the reviewer's name, used as a stand-in for the avatar
  # Google shows — the photos themselves are not ours to rehost.
  def review_initial(name)
    name.to_s.strip.first.to_s.upcase.presence || "•"
  end

  private
    def star_tag
      tag.svg STAR.html_safe, # rubocop:disable Rails/OutputSafety -- static markup above
              viewBox: "0 0 24 24", fill: "currentColor",
              "aria-hidden": "true", focusable: "false"
    end
end
