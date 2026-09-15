require "test_helper"

class SectionTest < ActiveSupport::TestCase
  setup { @page = create_page(title: "Page") }

  test "rejects an unknown kind" do
    section = @page.sections.new(kind: "carrousel_3d")
    assert_not section.valid?
    assert_includes section.errors.full_messages.join, "type de section"
  end

  test "each new section goes to the end of the list" do
    a = create_section(@page)
    b = create_section(@page)
    c = create_section(@page)
    assert_equal [ 0, 1, 2 ], [ a, b, c ].map(&:position)
  end

  test "move_down swaps two neighbours" do
    a = create_section(@page, heading: "A")
    b = create_section(@page, heading: "B")

    a.move_down!
    assert_equal [ "B", "A" ], @page.sections.ordered.reload.map(&:heading)
  end

  test "move_up on the first section is a no-op" do
    a = create_section(@page, heading: "A")
    create_section(@page, heading: "B")

    assert_not a.move_up!
    assert_equal [ "A", "B" ], @page.sections.ordered.reload.map(&:heading)
  end

  test "first? and last? bound the list" do
    a = create_section(@page)
    b = create_section(@page)
    assert a.first?
    assert b.last?
    assert_not a.last?
  end

  test "reposition! applies an explicit order" do
    a = create_section(@page, heading: "A")
    b = create_section(@page, heading: "B")
    c = create_section(@page, heading: "C")

    Section.reposition!(@page.sections, [ c.id, a.id, b.id ])
    assert_equal [ "C", "A", "B" ], @page.sections.ordered.reload.map(&:heading)
  end

  test "toggle_active flips visibility" do
    section = create_section(@page)
    assert section.active?
    section.toggle_active!
    assert_not section.reload.active?
  end

  test "setting falls back to the kind default" do
    section = create_section(@page, kind: "service_grid")
    assert_equal "3", section.setting(:columns)

    section.update!(settings: { "columns" => "4" })
    assert_equal "4", section.setting(:columns)
  end

  test "active scope hides disabled sections" do
    shown = create_section(@page)
    create_section(@page, active: false)
    assert_equal [ shown ], @page.sections.active.to_a
  end
end
