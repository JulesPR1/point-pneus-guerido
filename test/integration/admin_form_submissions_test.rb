require "test_helper"

class AdminFormSubmissionsTest < ActionDispatch::IntegrationTest
  setup do
    site_setting
    sign_in create_admin
    @contact = FormSubmission.create!(form_type: "contact", payload: {
      "nom" => "Dupont", "prenom" => "Marie", "email" => "marie@example.com",
      "tel" => "04 68 50 50 68", "sujet" => "Pneumatiques", "message" => "Avez-vous du 205/55 R16 ?"
    })
    @quote = FormSubmission.create!(form_type: "devis_pneus", status: "handled", payload: {
      "type_pneus" => "Hiver", "gamme" => "Occasion", "quantite" => "2",
      "largeur" => "195", "hauteur" => "65", "diametre" => "15",
      "marque_vehicule" => "Renault", "type_vehicule" => "Clio", "immatriculation" => "BB-456-CC",
      "nom" => "Martin", "email" => "martin@example.com", "tel" => "0612345678"
    })
  end

  test "lists every request" do
    get admin_form_submissions_path
    assert_response :success
    assert_select "tbody tr", 2
  end

  test "filters by form type" do
    get admin_form_submissions_path, params: { form_type: "devis_pneus" }
    assert_select "tbody tr", 1
    assert_match "Martin", response.body
  end

  test "filters by status" do
    get admin_form_submissions_path, params: { status: "new" }
    assert_select "tbody tr", 1
    assert_match "Dupont", response.body
  end

  test "searches on the contact details" do
    get admin_form_submissions_path, params: { q: "marie@example" }
    assert_select "tbody tr", 1
    assert_match "Dupont", response.body
  end

  test "shows the request with the labels of its form" do
    get admin_form_submission_path(@quote)
    assert_response :success
    assert_match "Type de pneu", response.body
    assert_match "Hiver", response.body
    assert_match "Immatriculation", response.body
    assert_match "BB-456-CC", response.body
  end

  test "changes the status and records a note" do
    patch admin_form_submission_path(@contact), params: {
      form_submission: { status: "in_progress", admin_notes: "Rappelée le 12/03." }
    }

    @contact.reload
    assert_equal "in_progress", @contact.status
    assert_equal "Rappelée le 12/03.", @contact.admin_notes
    assert_redirected_to admin_form_submission_path(@contact)
  end

  test "refuses a status that is not in the workflow" do
    patch admin_form_submission_path(@contact), params: { form_submission: { status: "perdu" } }
    assert_response :unprocessable_entity
    assert_equal "new", @contact.reload.status
  end

  test "the payload is never injected as markup" do
    hostile = FormSubmission.create!(form_type: "contact", payload: {
      "nom" => "<script>alert('xss')</script>", "email" => "x@example.com",
      "sujet" => "Autre demande", "message" => "<img src=x onerror=alert(1)>"
    })

    get admin_form_submission_path(hostile)
    assert_response :success
    assert_no_match(/<script>alert/, response.body)
    assert_no_match(/<img /, response.body)
    assert_match "&lt;script&gt;alert", response.body
    assert_match "&lt;img src=x onerror=alert(1)&gt;", response.body
  end

  test "destroys a request" do
    assert_difference "FormSubmission.count", -1 do
      delete admin_form_submission_path(@contact)
    end
    assert_redirected_to admin_form_submissions_path
  end
end
