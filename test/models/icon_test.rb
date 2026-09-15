require "test_helper"

class IconTest < ActiveSupport::TestCase
  test "every catalogued icon has a vendored Lucide file" do
    missing = Icon::NAMES.reject { |name| Icon::DIRECTORY.join("#{name}.svg").exist? }
    assert_empty missing, "manquant dans vendor/icons/lucide : #{missing.join(', ')} — lancer `bin/rails icons:import`"
  end

  test "each icon renders as non-empty markup without its svg wrapper" do
    Icon::NAMES.each do |name|
      body = Icon.body(name)
      assert body.present?, "#{name} est vide"
      assert_no_match(/<svg/, body, "#{name} garde son wrapper")
    end
  end

  test "an unknown name falls back to the default icon" do
    assert_equal Icon.body(Icon::DEFAULT), Icon.body("pas-une-icone")
    assert_not Icon.exist?("pas-une-icone")
  end

  test "guesses an icon from an accented title" do
    assert_equal "thermometer-snowflake", Icon.guess("Recharge climatisation")
    assert_equal "axis-3d", Icon.guess("Parallélisme / équilibrage")
    assert_equal Icon::DEFAULT, Icon.guess("Un titre sans mot-clé")
  end

  test "labels are unique so the picker never shows the same word twice" do
    labels = Icon::ALL.map(&:label)
    assert_equal labels.uniq.size, labels.size, "doublons : #{labels.tally.select { |_, n| n > 1 }.keys.join(', ')}"
  end
end
