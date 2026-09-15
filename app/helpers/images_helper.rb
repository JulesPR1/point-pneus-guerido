module ImagesHelper
  # Renders an Active Storage attachment through a named variant, with the
  # attributes that keep Lighthouse happy: intrinsic size, lazy loading and an
  # administrable alt text.
  def cms_image_tag(attachment, variant:, alt:, sizes: nil, eager: false, **options)
    return unless attachment&.attached?

    dimensions = intrinsic_dimensions(attachment, variant)

    image_tag attachment.variant(variant),
              alt: alt.to_s,
              loading: eager ? "eager" : "lazy",
              decoding: "async",
              fetchpriority: eager ? "high" : nil,
              sizes: sizes,
              **dimensions,
              **options
  end

  private
    # Active Storage records width/height when the blob is analysed; when the
    # analysis has not run yet we simply omit the attributes.
    def intrinsic_dimensions(attachment, variant)
      metadata = attachment.blob.metadata
      width, height = metadata["width"], metadata["height"]
      return {} if width.blank? || height.blank?

      limit = VARIANT_LIMITS[variant]
      return { width: width, height: height } if limit.nil?

      scale = [ limit[0].to_f / width, limit[1].to_f / height, 1.0 ].min
      { width: (width * scale).round, height: (height * scale).round }
    end

    VARIANT_LIMITS = {
      thumb: [ 320, 320 ], card: [ 800, 800 ], wide: [ 1600, 1600 ], og: [ 1200, 630 ]
    }.freeze
end
