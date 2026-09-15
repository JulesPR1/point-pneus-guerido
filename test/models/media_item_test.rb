require "test_helper"

class MediaItemTest < ActiveSupport::TestCase
  test "requires a file" do
    assert_not MediaItem.new(title: "Sans fichier").valid?
  end

  test "accepts a png" do
    media = MediaItem.new(alt_text: "Atelier")
    media.file.attach(image_fixture)
    assert media.valid?
  end

  test "rejects a non-image upload" do
    media = MediaItem.new
    media.file.attach(io: StringIO.new("#!/bin/sh\n"), filename: "script.sh", content_type: "application/x-sh")
    assert_not media.valid?
    assert_includes media.errors.full_messages.join, "image"
  end

  test "falls back to the filename for display" do
    media = MediaItem.new
    media.file.attach(image_fixture)
    media.save!
    assert_equal "photo.png", media.display_title
  end
end
