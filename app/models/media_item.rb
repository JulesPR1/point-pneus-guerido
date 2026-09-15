class MediaItem < ApplicationRecord
  CONTENT_TYPES = %w[image/jpeg image/png image/webp image/gif image/avif].freeze
  MAX_BYTE_SIZE = 10.megabytes

  has_one_attached :file do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 320, 240 ], format: :webp, saver: { quality: 72 }
    attachable.variant :card,  resize_to_limit: [ 800, 800 ], format: :webp, saver: { quality: 76 }
    attachable.variant :wide,  resize_to_limit: [ 1600, 1600 ], format: :webp, saver: { quality: 78 }
  end

  validates :file, presence: true
  validate  :file_is_a_supported_image

  scope :recent, -> { order(created_at: :desc) }

  def display_title = title.presence || file.filename.to_s

  private
    def file_is_a_supported_image
      return unless file.attached?

      errors.add(:file, "doit être une image (JPEG, PNG, WebP, GIF ou AVIF)") unless file.content_type.in?(CONTENT_TYPES)
      errors.add(:file, "ne doit pas dépasser #{MAX_BYTE_SIZE / 1.megabyte} Mo") if file.byte_size > MAX_BYTE_SIZE
    end
end
