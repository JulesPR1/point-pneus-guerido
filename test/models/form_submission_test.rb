require "test_helper"

class FormSubmissionTest < ActiveSupport::TestCase
  VALID_CONTACT = {
    "nom" => "Dupont", "email" => "client@example.com",
    "sujet" => "Pneumatiques", "message" => "Bonjour, avez-vous du 205/55 R16 ?"
  }.freeze

  test "a complete contact submission is valid" do
    submission = FormSubmission.new(form_type: "contact", payload: VALID_CONTACT)
    assert submission.valid?, submission.errors.full_messages.join(" / ")
  end

  test "rejects an unknown form type" do
    submission = FormSubmission.new(form_type: "devis_licorne", payload: {})
    assert_not submission.valid?
    assert_includes submission.errors.full_messages.join, "Formulaire inconnu"
  end

  test "reports every missing required field" do
    submission = FormSubmission.new(form_type: "contact", payload: {})
    assert_not submission.valid?
    assert_includes submission.errors.full_messages.join, "Nom"
    assert_includes submission.errors.full_messages.join, "Votre message"
  end

  test "rejects a malformed email" do
    submission = FormSubmission.new(form_type: "contact", payload: VALID_CONTACT.merge("email" => "pas-un-email"))
    assert_not submission.valid?
    assert_includes submission.errors.full_messages.join, "e-mail invalide"
  end

  test "rejects a malformed phone number" do
    submission = FormSubmission.new(form_type: "contact", payload: VALID_CONTACT.merge("tel" => "appelez-moi"))
    assert_not submission.valid?
    assert_includes submission.errors.full_messages.join, "téléphone invalide"
  end

  test "rejects a select value that was never offered" do
    submission = FormSubmission.new(form_type: "contact", payload: VALID_CONTACT.merge("sujet" => "Autre chose"))
    assert_not submission.valid?
    assert_includes submission.errors.full_messages.join, "valeur non proposée"
  end

  test "rejects a payload key the form does not declare" do
    submission = FormSubmission.new(form_type: "contact", payload: VALID_CONTACT.merge("is_admin" => "1"))
    assert_not submission.valid?
    assert_includes submission.errors.full_messages.join, "Champs inattendus"
  end

  test "enforces the declared maximum length" do
    submission = FormSubmission.new(form_type: "contact", payload: VALID_CONTACT.merge("nom" => "x" * 200))
    assert_not submission.valid?
    assert_includes submission.errors.full_messages.join, "caractères maximum"
  end

  test "checkbox lists accept several declared values" do
    submission = FormSubmission.new(form_type: "devis_mecanique", payload: mechanical_payload)
    assert submission.valid?, submission.errors.full_messages.join(" / ")
  end

  test "checkbox lists reject an undeclared value" do
    payload = mechanical_payload.merge("entretien" => [ "Freinage", "Peinture" ])
    submission = FormSubmission.new(form_type: "devis_mecanique", payload: payload)
    assert_not submission.valid?
  end

  test "denormalises the contact columns on save" do
    submission = FormSubmission.create!(form_type: "devis_mecanique", payload: mechanical_payload)
    assert_equal "Marie Dupont", submission.contact_name
    assert_equal "client@example.com", submission.contact_email
    assert_equal "04 68 50 50 68", submission.contact_phone
  end

  test "new is the default status and the workflow accepts the four states" do
    submission = FormSubmission.create!(form_type: "contact", payload: VALID_CONTACT)
    assert submission.status_new?

    %w[in_progress handled archived].each do |status|
      submission.update!(status: status)
      assert_equal status, submission.reload.status
    end
  end

  test "rejects an unknown status" do
    submission = FormSubmission.new(form_type: "contact", payload: VALID_CONTACT, status: "perdu")
    assert_not submission.valid?
    assert_includes submission.errors.attribute_names, :status
  end

  test "labelled payload follows the declared field order" do
    submission = FormSubmission.create!(form_type: "contact", payload: VALID_CONTACT)
    assert_equal [ "Nom", "E-mail", "Sujet", "Votre message" ], submission.labelled_payload.map(&:first)
  end

  test "open_requests covers new and in progress only" do
    a = FormSubmission.create!(form_type: "contact", payload: VALID_CONTACT)
    b = FormSubmission.create!(form_type: "contact", payload: VALID_CONTACT, status: "in_progress")
    FormSubmission.create!(form_type: "contact", payload: VALID_CONTACT, status: "handled")

    assert_equal [ a, b ].map(&:id).sort, FormSubmission.open_requests.pluck(:id).sort
  end

  private
    def mechanical_payload
      {
        "entretien" => [ "Freinage", "Vidange" ],
        "marque_vehicule" => "Peugeot", "type_vehicule" => "307", "immatriculation" => "AA-123-BB",
        "nom" => "Dupont", "prenom" => "Marie",
        "email" => "client@example.com", "tel" => "04 68 50 50 68"
      }
    end
end
