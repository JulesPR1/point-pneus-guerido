class SectionItem < ApplicationRecord
  include Positionable

  belongs_to :section, inverse_of: :items, touch: true

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 320, 320 ], format: :webp, saver: { quality: 72 }
    attachable.variant :card,  resize_to_limit: [ 800, 800 ], format: :webp, saver: { quality: 76 }
  end

  validates :link_url, length: { maximum: 500 }, allow_blank: true
  validates :icon, inclusion: { in: Icon::NAMES, message: "n'existe pas dans la bibliothèque" }, allow_blank: true
  validate  :link_url_is_safe

  normalizes :icon, with: ->(value) { value.to_s.strip.presence }

  positioned_within :section, list: :items

  def lines = body.to_s.split("\n").map(&:strip).reject(&:blank?)

  private
    # Blocks javascript:/data: URLs typed into the backoffice from reaching the public site.
    def link_url_is_safe
      return if link_url.blank? || SafeUrl.safe?(link_url)

      errors.add(:link_url, "doit être un chemin interne ou une URL http(s), mailto: ou tel:")
    end
end
