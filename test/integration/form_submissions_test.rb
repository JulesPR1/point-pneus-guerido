require "test_helper"

class FormSubmissionsTest < ActionDispatch::IntegrationTest
  setup do
    site_setting
    @page = create_page(title: "Contact", slug: "contact", home: true)
    create_section(@page, kind: "form", heading: "Nous écrire",
                   settings: { "form_type" => "contact" })
  end

  test "the form is rendered from its definition" do
    get root_path
    assert_select "form[action=?]", form_submissions_path
    assert_select "input[name='submission[nom]'][required]"
    assert_select "select[name='submission[sujet]']"
    assert_select "textarea[name='submission[message]']"
    assert_select "input[name=form_type][value=contact]", visible: false
  end

  test "a valid submission is stored and confirmed" do
    assert_difference "FormSubmission.count", 1 do
      post form_submissions_path, params: valid_params
    end

    submission = FormSubmission.last
    assert_equal "contact", submission.form_type
    assert_equal "new", submission.status
    assert_equal "Marie Dupont", submission.contact_name
    assert_equal "Bonjour, avez-vous du 205/55 R16 ?", submission.payload["message"]

    assert_redirected_to "#{page_path('contact')}#demande"
    follow_redirect!
    assert_select ".toaster .toast--notice .toast__text", text: /bien enregistré/
    assert_select ".toast__close"
  end

  test "an incomplete submission is rejected and the page is re-rendered with the errors" do
    assert_no_difference "FormSubmission.count" do
      post form_submissions_path, params: valid_params(message: "")
    end

    assert_response :unprocessable_entity
    assert_select ".error-summary", /Votre message/
  end

  test "an invalid email is rejected" do
    assert_no_difference "FormSubmission.count" do
      post form_submissions_path, params: valid_params(email: "pas-un-email")
    end
    assert_response :unprocessable_entity
  end

  test "submitted values are kept so the visitor does not retype everything" do
    post form_submissions_path, params: valid_params(message: "")
    assert_select "input[name='submission[nom]'][value=Dupont]"
  end

  test "extra parameters are dropped rather than stored" do
    post form_submissions_path, params: valid_params.deep_merge(submission: { status: "handled", role: "admin" })

    submission = FormSubmission.last
    assert_equal "new", submission.status
    assert_not_includes submission.payload.keys, "role"
  end

  test "a honeypot hit is silently accepted but stores nothing" do
    assert_no_difference "FormSubmission.count" do
      post form_submissions_path, params: valid_params.merge(website: "http://spam.example")
    end
    assert_redirected_to page_path("contact")
  end

  test "an unknown form type is refused" do
    assert_no_difference "FormSubmission.count" do
      post form_submissions_path, params: { form_type: "devis_licorne", submission: { nom: "X" } }
    end
    assert_redirected_to root_path
  end

  test "the tyre quote form stores the full dimension set" do
    post form_submissions_path, params: {
      form_type: "devis_pneus", return_slug: "contact",
      submission: {
        type_pneus: "Été", gamme: "Marque premium", quantite: "4",
        largeur: "205", hauteur: "55", diametre: "16",
        marque_vehicule: "Peugeot", type_vehicule: "307", immatriculation: "AA-123-BB",
        nom: "Dupont", email: "client@example.com", tel: "0468505068"
      }
    }

    submission = FormSubmission.last
    assert_equal "devis_pneus", submission.form_type
    assert_equal %w[205 55 16], submission.payload.values_at("largeur", "hauteur", "diametre")
  end

  test "the rate limit stops a flood of submissions" do
    9.times { post form_submissions_path, params: valid_params }

    assert_equal 8, FormSubmission.count
    assert_match "Trop de demandes", flash[:alert]
  end

  private
    def valid_params(**overrides)
      {
        form_type: "contact",
        return_slug: "contact",
        submission: {
          nom: "Dupont", prenom: "Marie", email: "client@example.com", tel: "04 68 50 50 68",
          sujet: "Pneumatiques", message: "Bonjour, avez-vous du 205/55 R16 ?"
        }.merge(overrides)
      }
    end
end
