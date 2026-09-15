module CmsHelper
  # Renders backoffice-authored copy.
  #
  # The format is deliberately tiny and safe: blank line = new paragraph,
  # "- " = list item, "## " = sub-heading. Everything is escaped first, so no
  # markup typed into the backoffice can reach the page.
  def cms_text(body, class_name: "prose")
    blocks = build_blocks(body)
    return if blocks.empty?

    tag.div(class: class_name) { safe_join(blocks) }
  end

  # First paragraph only — used for section ledes.
  def cms_lede(body)
    first = body.to_s.split(/\n{2,}/).first
    return if first.blank?

    simple_format_line(first)
  end

  def cms_lines(body) = body.to_s.split("\n").map(&:strip).reject(&:blank?)

  # The heading level to use for the titles inside a section's items.
  def sub_heading_tag = :"h#{(@section_heading_level || 2) + 1}"

  # A hero title can mark one word with *asterisks* to have it picked out in yellow.
  def hero_headline(text)
    ERB::Util.html_escape(text.to_s)
      .gsub(/\*(.+?)\*/) { "<em>#{Regexp.last_match(1)}</em>" }
      .html_safe # rubocop:disable Rails/OutputSafety -- escaped above
  end

  def cta_button_class(item, tone)
    secondary = item.value.to_s.downcase.start_with?("second")

    case tone
    when "dark"   then secondary ? "btn--on-dark" : "btn--primary"
    when "signal" then secondary ? "btn--ghost" : ""
    else               secondary ? "btn--ghost" : "btn--primary"
    end
  end

  private
    def build_blocks(body)
      blocks = []
      buffer = []
      flush = -> { blocks << tag.ul(safe_join(buffer)) if buffer.any?; buffer = [] }

      body.to_s.split(/\r?\n/).each do |raw|
        line = raw.strip

        if line.blank?
          flush.call
        elsif line.start_with?("- ")
          buffer << tag.li(simple_format_line(line.delete_prefix("- ")))
        elsif line.start_with?("## ")
          flush.call
          blocks << tag.h3(line.delete_prefix("## "))
        else
          flush.call
          blocks << tag.p(simple_format_line(line))
        end
      end
      flush.call
      blocks
    end

    # Escapes first, then re-introduces only **bold** and [label](url).
    def simple_format_line(text)
      escaped = ERB::Util.html_escape(text.to_s)
      escaped = escaped.gsub(/\*\*(.+?)\*\*/) { "<strong>#{Regexp.last_match(1)}</strong>" }
      escaped = escaped.gsub(%r{\[([^\]]+)\]\(((?:https?://|/|mailto:|tel:)[^)\s]+)\)}) do
        %(<a href="#{Regexp.last_match(2)}">#{Regexp.last_match(1)}</a>)
      end
      escaped.html_safe # rubocop:disable Rails/OutputSafety -- input was escaped above
    end
end
