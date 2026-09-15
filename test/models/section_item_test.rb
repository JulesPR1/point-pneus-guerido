require "test_helper"

class SectionItemTest < ActiveSupport::TestCase
  setup do
    @section = create_section(create_page(title: "Page"), kind: "service_grid")
  end

  test "accepts internal paths and safe schemes" do
    [ "/contact", "#demande", "https://example.com", "mailto:a@b.fr", "tel:+33468505068" ].each do |url|
      assert @section.items.new(title: "Lien", link_url: url).valid?, "#{url} devrait être accepté"
    end
  end

  test "rejects a javascript url typed into the backoffice" do
    item = @section.items.new(title: "Lien", link_url: "javascript:alert(1)")
    assert_not item.valid?
    assert_includes item.errors.attribute_names, :link_url
  end

  test "items keep their own ordering inside a section" do
    a = @section.items.create!(title: "A")
    b = @section.items.create!(title: "B")
    b.move_up!
    assert_equal [ "B", "A" ], @section.items.ordered.reload.map(&:title)
  end

  test "accepts an icon taken from the library and refuses anything else" do
    assert @section.items.new(title: "Freins", icon: "disc").valid?
    assert @section.items.new(title: "Freins", icon: "").valid?

    item = @section.items.new(title: "Freins", icon: "logo-maison")
    assert_not item.valid?
    assert_includes item.errors.attribute_names, :icon
  end

  test "blanks out an icon left empty in the form" do
    item = @section.items.create!(title: "Freins", icon: "  ")
    assert_nil item.icon
  end

  test "lines splits a multi-line body" do
    item = @section.items.create!(title: "Freinage", body: "Disques\n\nPlaquettes\n")
    assert_equal %w[Disques Plaquettes], item.lines
  end
end
