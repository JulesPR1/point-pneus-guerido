module IconsHelper
  # Renders one icon from the library (see Icon) in a 24×24 box, stroked with
  # currentColor. The wrapper is rebuilt here rather than taken from the source
  # file so that six icons standing side by side in a services grid always share
  # one stroke weight.
  def icon_tag(name, size: nil)
    tag.svg(Icon.body(name).html_safe, # rubocop:disable Rails/OutputSafety -- vendored Lucide markup
            viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
            width: size, height: size,
            "stroke-width": 1.7, "stroke-linecap": "round", "stroke-linejoin": "round",
            "aria-hidden": "true", focusable: "false")
  end

  # Icon of a CMS item: the one picked in the back-office, or a guess from the
  # title for items saved before the picker existed.
  def cms_icon(item, fallback: Icon::DEFAULT)
    icon_tag(icon_name_for(item, fallback: fallback))
  end

  private
    def icon_name_for(item, fallback:)
      picked = item.try(:icon).to_s
      return picked if Icon.exist?(picked)

      Icon.guess(item.try(:title), fallback: fallback)
    end
end
