require "test_helper"

class FormDefinitionTest < ActiveSupport::TestCase
  test "filter keeps only declared keys" do
    definition = FormDefinition.fetch("contact")
    filtered = definition.filter("nom" => "Dupont", "role" => "admin")

    assert_equal %w[nom], filtered.keys
  end

  test "filter trims values and drops blanks" do
    filtered = FormDefinition.fetch("contact").filter("nom" => "  Dupont  ", "prenom" => "   ")

    assert_equal "Dupont", filtered["nom"]
    assert_not_includes filtered.keys, "prenom"
  end

  test "filter normalises checkbox lists to arrays" do
    filtered = FormDefinition.fetch("devis_mecanique").filter("entretien" => [ "Freinage", "" ])

    assert_equal [ "Freinage" ], filtered["entretien"]
  end

  test "the tyre form carries the dimensions read off the sidewall" do
    definition = FormDefinition.fetch("devis_pneus")

    assert_includes definition.field("largeur").options, "205"
    assert_includes definition.field("hauteur").options, "55"
    assert_includes definition.field("diametre").options, "16"
    assert_includes definition.field("indice_vitesse").options, "V"
  end
end
