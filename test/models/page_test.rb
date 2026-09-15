require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "requires a title" do
    page = Page.new(title: "")
    assert_not page.valid?
    assert_includes page.errors.attribute_names, :title
  end

  test "derives the slug from the title" do
    assert_equal "geometrie-3d", create_page(title: "Géométrie 3D").slug
  end

  test "normalises a slug typed by hand" do
    assert_equal "devis-pneus", create_page(title: "Devis", slug: "Devis Pneus").slug
  end

  test "rejects a duplicate slug" do
    create_page(title: "Contact", slug: "contact")
    duplicate = Page.new(title: "Contact bis", slug: "contact")
    assert_not duplicate.valid?
  end

  test "rejects a reserved slug" do
    page = Page.new(title: "Admin", slug: "admin")
    assert_not page.valid?
    assert_includes page.errors.full_messages.join, "réservé"
  end

  test "rejects being its own parent" do
    page = create_page(title: "Entretiens")
    page.parent_id = page.id
    assert_not page.valid?
  end

  test "publishing stamps published_at once" do
    page = create_page(title: "Brouillon", status: :draft)
    assert_nil page.published_at

    page.publish!
    first_stamp = page.published_at
    assert_not_nil first_stamp

    page.unpublish!
    page.publish!
    assert_equal first_stamp.to_i, page.reload.published_at.to_i
  end

  test "home is served at the root path" do
    assert_equal "/", create_page(title: "Accueil", home: true).path
    assert_equal "/contact", create_page(title: "Contact").path
  end

  test "published scope excludes drafts" do
    published = create_page(title: "Publiée")
    create_page(title: "Cachée", status: :draft)
    assert_equal [ published ], Page.published.to_a
  end

  test "primary heading section skips banners" do
    page = create_page(title: "Page")
    banner = create_section(page, kind: "banner", heading: "Promo")
    hero   = create_section(page, kind: "hero", heading: "Titre")
    assert_equal hero, Page.primary_heading_section([ banner, hero ])
  end

  test "destroying a page destroys its sections and items" do
    page = create_page(title: "Page")
    section = create_section(page, kind: "checklist")
    section.items.create!(title: "Un point")

    assert_difference [ "Section.count", "SectionItem.count" ], -1 do
      page.destroy
    end
  end
end
