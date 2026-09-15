class Section < ApplicationRecord
  include Positionable

  belongs_to :page, inverse_of: :sections, touch: true
  has_many :items, -> { order(:position, :id) }, class_name: "SectionItem", dependent: :destroy, inverse_of: :section

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 320, 320 ], format: :webp, saver: { quality: 72 }
    attachable.variant :card,  resize_to_limit: [ 800, 800 ], format: :webp, saver: { quality: 76 }
    attachable.variant :wide,  resize_to_limit: [ 1600, 1200 ], format: :webp, saver: { quality: 78 }
  end

  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 480, 480 ], format: :webp, saver: { quality: 72 }
    attachable.variant :wide,  resize_to_limit: [ 1600, 1600 ], format: :webp, saver: { quality: 78 }
  end

  validates :kind, presence: true, inclusion: { in: SectionKind::KEYS, message: "n'est pas un type de section connu" }
  validates :heading, length: { maximum: 200 }, allow_blank: true

  positioned_within :page, list: :sections

  scope :active, -> { where(active: true) }

  def definition = SectionKind.find(kind)
  def kind_label = definition&.label || kind

  def setting(name)
    settings&.[](name.to_s).presence || definition&.setting_default(name)
  end

  def admin_title
    heading.presence || eyebrow.presence || kind_label
  end

  def toggle_active! = update!(active: !active?)
end
