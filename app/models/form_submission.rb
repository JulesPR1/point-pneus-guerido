class FormSubmission < ApplicationRecord
  STATUSES = { new: "new", in_progress: "in_progress", handled: "handled", archived: "archived" }.freeze

  enum :status, STATUSES, prefix: :status, validate: true

  validates :form_type, presence: true, inclusion: { in: FormDefinition::KEYS }
  validate  :payload_matches_definition

  before_validation :extract_contact_columns

  scope :recent,       -> { order(created_at: :desc) }
  scope :of_type,      ->(type) { where(form_type: type) if type.present? }
  scope :with_status,  ->(status) { where(status: status) if status.present? }
  scope :open_requests, -> { where(status: %w[new in_progress]) }

  STATUS_LABELS = {
    "new" => "Nouveau", "in_progress" => "En cours", "handled" => "Traité", "archived" => "Archivé"
  }.freeze

  def self.status_options = STATUS_LABELS.map { |value, label| [ label, value ] }

  def definition = FormDefinition.find(form_type)
  def type_label = definition&.label || form_type
  def status_label = STATUS_LABELS.fetch(status, status)

  # [label, displayed value] pairs, in the order the form declares them.
  def labelled_payload
    return [] unless definition

    definition.fields.filter_map do |field|
      value = payload&.[](field.key)
      next if value.blank?

      [ field.label, Array(value).join(", ") ]
    end
  end

  def summary
    [ contact_name, payload&.[]("sujet") || payload&.[]("entretien")&.then { Array(_1).join(", ") } ]
      .compact_blank.join(" — ")
  end

  private
    def extract_contact_columns
      return if payload.blank?

      self.contact_name  = [ payload["prenom"], payload["nom"] ].compact_blank.join(" ").presence
      self.contact_email = payload["email"].presence
      self.contact_phone = payload["tel"].presence
    end

    def payload_matches_definition
      definition = FormDefinition.find(form_type)
      return errors.add(:base, "Formulaire inconnu.") if definition.nil?

      self.payload ||= {}
      unknown = payload.keys - definition.keys
      errors.add(:base, "Champs inattendus : #{unknown.join(', ')}") if unknown.any?

      definition.fields.each { |field| validate_field(field) }
    end

    def validate_field(field)
      value = payload[field.key]
      value = Array(value).compact_blank if field.checkboxes?

      if field.required && value.blank?
        return errors.add(:base, "#{field.label} : ce champ est obligatoire.")
      end
      return if value.blank?

      if field.choice?
        invalid = Array(value) - Array(field.options)
        return errors.add(:base, "#{field.label} : valeur non proposée.") if invalid.any?
      elsif value.to_s.length > field.maxlength
        return errors.add(:base, "#{field.label} : #{field.maxlength} caractères maximum.")
      end

      case field.type
      when :email
        errors.add(:base, "#{field.label} : adresse e-mail invalide.") unless value.to_s.match?(URI::MailTo::EMAIL_REGEXP)
      when :tel
        errors.add(:base, "#{field.label} : numéro de téléphone invalide.") unless value.to_s.match?(/\A[+0-9 ().\-]{6,25}\z/)
      end
    end
end
