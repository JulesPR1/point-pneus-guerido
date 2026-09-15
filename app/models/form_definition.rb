# Declarative description of the public forms.
#
# One definition drives three things at once: the public form markup, the
# server-side validation of a FormSubmission, and the labelled read-only view in
# the backoffice. Adding a field in one place is therefore enough.
class FormDefinition
  Field = Data.define(:key, :label, :type, :required, :options, :hint, :placeholder, :maxlength, :width) do
    def select?     = type == :select
    def radio?      = type == :radio
    def checkboxes? = type == :checkboxes
    def textarea?   = type == :textarea
    def choice?     = select? || radio? || checkboxes?
  end

  Group = Data.define(:title, :description, :fields)

  attr_reader :key, :label, :short_label, :intro, :submit_label, :success_message, :groups

  def initialize(key:, label:, short_label:, intro:, submit_label:, success_message:, groups:)
    @key             = key.to_s
    @label           = label
    @short_label     = short_label
    @intro           = intro
    @submit_label    = submit_label
    @success_message = success_message
    @groups = groups.map do |g|
      Group.new(title: g[:title], description: g[:description], fields: g[:fields].map { build_field(_1) })
    end
  end

  def fields = @fields ||= groups.flat_map(&:fields)
  def field(key) = fields.find { |f| f.key == key.to_s }
  def keys = fields.map(&:key)

  # Keeps only keys this form declares — nothing a crafted request adds is stored.
  def filter(raw)
    raw = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
    fields.each_with_object({}) do |field, out|
      value = raw[field.key] || raw[field.key.to_sym]
      value = Array(value).map { |v| v.to_s.strip }.reject(&:blank?) if field.checkboxes?
      value = value.to_s.strip unless field.checkboxes?
      out[field.key] = value if value.present?
    end
  end

  def build_field(attrs)
    Field.new(
      key: attrs.fetch(:key).to_s,
      label: attrs.fetch(:label),
      type: attrs.fetch(:type, :string),
      required: attrs.fetch(:required, false),
      options: attrs[:options],
      hint: attrs[:hint],
      placeholder: attrs[:placeholder],
      maxlength: attrs.fetch(:maxlength, 120),
      width: attrs.fetch(:width, :full)
    )
  end
  private :build_field

  VEHICLE_GROUP = {
    title: "Votre véhicule",
      description: "Ces informations nous permettent de vous proposer la bonne référence.",
      fields: [
        { key: "marque_vehicule", label: "Marque du véhicule", required: true, placeholder: "ex. Peugeot", width: :half },
        { key: "type_vehicule", label: "Modèle", required: true, placeholder: "ex. 307", width: :half },
        { key: "immatriculation", label: "Immatriculation", required: true, placeholder: "AA-123-BB", width: :half,
          hint: "Utilisée uniquement pour identifier la référence exacte." },
        { key: "date_circulation", label: "Date de mise en circulation", width: :half, placeholder: "MM/AAAA" },
        { key: "motorisation", label: "Motorisation", placeholder: "ex. 1,4i", width: :half }
      ]
  }.freeze

  CONTACT_GROUP = {
      title: "Vos coordonnées",
      description: nil,
      fields: [
        { key: "nom", label: "Nom", required: true, width: :half },
        { key: "prenom", label: "Prénom", width: :half },
        { key: "email", label: "E-mail", type: :email, required: true, width: :half },
        { key: "tel", label: "Téléphone", type: :tel, required: true, width: :half },
        { key: "adresse", label: "Adresse", maxlength: 200 },
        { key: "cp", label: "Code postal", maxlength: 10, width: :half },
        { key: "ville", label: "Ville", width: :half },
        { key: "remarques", label: "Remarques", type: :textarea, maxlength: 2000 }
      ]
  }.freeze

  LARGEURS = (135..375).step(5).map(&:to_s).freeze
  HAUTEURS  = (25..80).step(5).to_a.reverse.map(&:to_s).freeze
  DIAMETRES = (13..24).map(&:to_s).freeze
  CHARGES   = (68..120).map(&:to_s).freeze
  VITESSES  = %w[S T H V W Y Z].freeze

  ALL = [
    new(key: :devis_pneus,
        label: "Devis pneus",
        short_label: "Devis pneus",
        intro: "Décrivez le pneu recherché : nous revenons vers vous avec un prix monté, équilibré, valves comprises.",
        submit_label: "Envoyer ma demande de devis",
        success_message: "Votre demande de devis pneus est bien enregistrée. Nous vous recontactons rapidement.",
        groups: [
          { title: "Le pneu recherché", description: nil, fields: [
            { key: "type_pneus", label: "Type de pneu", type: :radio, required: true, options: [ "Été", "Hiver", "Toute saison" ] },
            { key: "gamme", label: "Gamme souhaitée", type: :radio, required: true, options: [ "Eco budget", "Marque premium", "Occasion" ] },
            { key: "quantite", label: "Quantité", required: true, placeholder: "ex. 4", maxlength: 3, width: :half },
            { key: "specificite", label: "Spécificité", type: :radio,
              options: [ "Aucune", "Pneus type Run Flat (principalement BMW nouveaux modèles)", "Pneus type Pax System (option Renault Scénic)" ] }
          ] },
          { title: "Dimensions", description: "Relevez-les sur le flanc du pneu, par exemple 205/55 R16 91 V.", fields: [
            { key: "largeur", label: "Largeur", type: :select, required: true, options: LARGEURS, width: :fifth },
            { key: "hauteur", label: "Hauteur", type: :select, required: true, options: HAUTEURS, width: :fifth },
            { key: "diametre", label: "Diamètre", type: :select, required: true, options: DIAMETRES, width: :fifth },
            { key: "indice_charge", label: "Indice de charge", type: :select, options: CHARGES, width: :fifth },
            { key: "indice_vitesse", label: "Indice de vitesse", type: :select, options: VITESSES, width: :fifth }
          ] },
          VEHICLE_GROUP,
          CONTACT_GROUP
        ]),

    new(key: :devis_mecanique,
        label: "Devis mécanique et entretien",
        short_label: "Devis mécanique",
        intro: "Indiquez l'intervention souhaitée et votre véhicule : nous vous répondons avec un chiffrage détaillé.",
        submit_label: "Envoyer ma demande de devis",
        success_message: "Votre demande de devis mécanique est bien enregistrée. Nous vous recontactons rapidement.",
        groups: [
          { title: "L'intervention", description: nil, fields: [
            { key: "entretien", label: "Type d'entretien", type: :checkboxes, required: true,
              options: [ "Freinage", "Kit de distribution", "Embrayage", "Échappement", "Révision", "Vidange", "Pompe à eau", "Autre réparation" ] },
            { key: "marques", label: "Marque(s) de pièces souhaitée(s)", maxlength: 200 }
          ] },
          VEHICLE_GROUP,
          CONTACT_GROUP
        ]),

    new(key: :contact,
        label: "Demande d'informations",
        short_label: "Contact",
        intro: "Une question sur une prestation, une disponibilité, un délai ? Écrivez-nous.",
        submit_label: "Envoyer ma demande",
        success_message: "Votre message est bien enregistré. Nous vous répondons dès que possible.",
        groups: [
          { title: nil, description: nil, fields: [
            { key: "nom", label: "Nom", required: true, width: :half },
            { key: "prenom", label: "Prénom", width: :half },
            { key: "email", label: "E-mail", type: :email, required: true, width: :half },
            { key: "tel", label: "Téléphone", type: :tel, width: :half },
            { key: "sujet", label: "Sujet", type: :select, required: true,
              options: [ "Pneumatiques", "Mécanique et entretien", "Géométrie 3D", "Climatisation", "Rénovation de phares", "Pièces détachées", "Autre demande" ] },
            { key: "message", label: "Votre message", type: :textarea, required: true, maxlength: 4000 }
          ] }
        ])
  ].freeze

  BY_KEY = ALL.index_by(&:key).freeze
  KEYS   = ALL.map(&:key).freeze

  def self.find(key) = BY_KEY[key.to_s]
  def self.fetch(key) = BY_KEY.fetch(key.to_s)
  def self.options_for_select = ALL.map { |d| [ d.label, d.key ] }
end
