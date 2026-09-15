# One definition of "safe to render" for a link typed into the backoffice:
# an internal path, or an http(s) / mailto: / tel: URL. Anything else —
# javascript:, data: — is rejected before it can reach a public page.
module SafeUrl
  SCHEMES = %r{\A(?:https?|mailto|tel):}i

  def self.safe?(url)
    url = url.to_s.strip
    return false if url.blank?

    url.start_with?("/", "#") || url.match?(SCHEMES)
  end
end
