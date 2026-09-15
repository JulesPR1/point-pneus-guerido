module FormsHelper
  def form_input_type(field)
    case field.type
    when :email then "email"
    when :tel   then "tel"
    else "text"
    end
  end

  def form_inputmode(field)
    case field.type
    when :email then "email"
    when :tel   then "tel"
    else field.key.in?(%w[quantite cp]) ? "numeric" : nil
    end
  end

  AUTOCOMPLETE = {
    "nom" => "family-name", "prenom" => "given-name", "email" => "email", "tel" => "tel",
    "adresse" => "street-address", "cp" => "postal-code", "ville" => "address-level2"
  }.freeze

  def form_autocomplete(field) = AUTOCOMPLETE[field.key]
end
