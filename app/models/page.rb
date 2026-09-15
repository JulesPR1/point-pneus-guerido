class Page < ApplicationRecord
  RESERVED_SLUGS = %w[admin rails assets up sitemap.xml robots.txt demandes].freeze

  has_many :sections, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :page
  belongs_to :parent, class_name: "Page", optional: true
  has_many :children, -> { order(:position, :id) }, class_name: "Page", foreign_key: :parent_id,
           inverse_of: :parent, dependent: :nullify

  has_one_attached :og_image do |attachable|
    attachable.variant :og, resize_to_fill: [ 1200, 630 ], format: :jpeg, saver: { quality: 80 }
  end

  enum :status, { draft: "draft", published: "published" }, validate: true

  before_validation :generate_slug
  before_validation :normalize_home
  before_save :stamp_published_at

  validates :title, presence: true, length: { maximum: 160 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 120 },
                   format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "n'accepte que des minuscules, chiffres et tirets" },
                   exclusion: { in: RESERVED_SLUGS, message: "est réservé" }
  validates :seo_title, length: { maximum: 70 }, allow_blank: true
  validates :meta_description, length: { maximum: 200 }, allow_blank: true
  validate  :parent_is_not_self

  scope :ordered,    -> { order(:position, :id) }
  scope :in_nav,     -> { where(show_in_nav: true) }
  scope :top_level,  -> { where(parent_id: nil) }

  def self.home = find_by(home: true)

  # Admin URLs are built from to_param (the slug); accept an id as well so a
  # bookmarked numeric URL keeps working after a slug is renamed.
  def self.locate(param)
    find_by(slug: param.to_s) || find(param)
  end

  # Which section carries the page's single H1. Banners never do.
  def self.primary_heading_section(sections)
    sections.find { |s| s.heading.present? && s.kind != "banner" }
  end

  def to_param = slug

  def nav_title = nav_label.presence || title
  def document_title = seo_title.presence || title
  def path = home? ? "/" : "/#{slug}"

  def publish!   = update!(status: :published)
  def unpublish! = update!(status: :draft)

  def visible_sections = sections.select(&:active?)

  private
    def generate_slug
      self.slug = (slug.presence || title.to_s).parameterize if slug.blank? || title_changed? && slug.blank?
      self.slug = slug.to_s.parameterize.presence
    end

    def normalize_home
      self.show_in_nav = true if home? && show_in_nav.nil?
    end

    def stamp_published_at
      self.published_at ||= Time.current if published?
    end

    def parent_is_not_self
      errors.add(:parent_id, "ne peut pas être la page elle-même") if parent_id.present? && parent_id == id
    end
end
