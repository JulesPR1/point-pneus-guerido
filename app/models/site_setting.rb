# Single-row model holding the details that repeat across the whole site
# (header, footer, contact and hours sections, structured data).
class SiteSetting < ApplicationRecord
  has_one_attached :logo
  has_one_attached :default_og_image do |attachable|
    attachable.variant :og, resize_to_fill: [ 1200, 630 ], format: :jpeg, saver: { quality: 80 }
  end

  validates :company_name, presence: true
  validates :phone, presence: true, on: :update
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  # Both feed an iframe src / an outbound link on every page of the site, so a
  # javascript: or data: URL typed into the backoffice must not get that far.
  validates :map_embed_url, :map_link_url,
            format: { with: %r{\Ahttps?://\S+\z}i, message: "doit être une URL http(s)" }, allow_blank: true

  def self.instance = first || create!(company_name: "Point Pneus Guerido")

  def full_address = [ address_line, [ postal_code, city ].compact_blank.join(" ") ].compact_blank.join(", ")

  def phone_link = "tel:+33#{phone.to_s.gsub(/\D/, '').sub(/\A0/, '')}"

  # "Lundi – vendredi|8h – 12h / 14h – 18h30" per line
  def hours
    opening_hours.to_s.lines.filter_map do |line|
      day, slot = line.strip.split("|", 2)
      next if day.blank?

      [ day.strip, slot.to_s.strip ]
    end
  end
end
