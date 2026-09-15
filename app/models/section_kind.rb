# Registry of the section types the page builder can render.
#
# Adding a new type means adding an entry here plus a matching partial in
# app/views/sections/_<key>.html.erb — no migration, no new table, no change to
# Page or Section. Every admin form (fields, items, settings) is derived from
# this registry, so a new type is editable in the backoffice as soon as it is
# declared.
class SectionKind
  Field   = Data.define(:name, :label, :hint)
  Setting = Data.define(:name, :label, :type, :options, :default, :hint)

  attr_reader :key, :label, :description, :fields, :images, :item, :settings

  def initialize(key:, label:, description:, fields: {}, images: :none, item: nil, settings: [])
    @key         = key.to_s
    @label       = label
    @description = description
    @fields      = fields.map { |name, opts| Field.new(name: name.to_s, label: opts[:label], hint: opts[:hint]) }
    @images      = images # :none, :one or :many
    @item        = item&.then { |i| ItemDefinition.new(**i) }
    @settings    = settings.map { |s| Setting.new(name: s[:name].to_s, label: s[:label], type: s.fetch(:type, :string), options: s[:options], default: s[:default], hint: s[:hint]) }
  end

  class ItemDefinition
    attr_reader :label, :plural, :image, :icon, :fields

    # icon: true adds the icon picker to the item form, for the kinds whose
    # partial actually draws one (see IconsHelper#cms_icon).
    def initialize(label:, plural:, fields:, image: false, icon: false)
      @label  = label
      @plural = plural
      @image  = image
      @icon   = icon
      @fields = fields.map { |name, opts| Field.new(name: name.to_s, label: opts[:label], hint: opts[:hint]) }
    end

    def field?(name) = fields.any? { |f| f.name == name.to_s }
  end

  def uses?(field_name) = fields.any? { |f| f.name == field_name.to_s }
  def items? = item.present?
  def one_image? = images == :one
  def many_images? = images == :many
  def image? = images != :none
  def setting_default(name) = settings.find { |s| s.name == name.to_s }&.default
  def setting(name) = settings.find { |s| s.name == name.to_s }

  TONE = { name: :tone, label: "Fond de la section", type: :select,
           options: %w[paper dark signal], default: "paper" }.freeze

  ALL = [
    new(key: :hero, label: "Hero", description: "Bandeau d'ouverture : accroche, texte d'introduction, boutons et visuel.",
        fields: { eyebrow: { label: "Surtitre", hint: "Court, affiché au-dessus du titre" },
                  heading: { label: "Titre principal" },
                  subheading: { label: "Sous-titre" },
                  body: { label: "Texte d'introduction" } },
        images: :one,
        item: { label: "Bouton", plural: "Boutons",
                fields: { title: { label: "Libellé" }, link_url: { label: "Lien" },
                          value: { label: "Style", hint: "principal ou secondaire" } } }),

    new(key: :text_image, label: "Texte + image", description: "Un bloc de texte et un visuel côte à côte.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" },
                  subheading: { label: "Sous-titre" }, body: { label: "Texte" } },
        images: :one,
        item: { label: "Point clé", plural: "Points clés", fields: { title: { label: "Texte" } } },
        settings: [ TONE, { name: :image_side, label: "Position de l'image", type: :select, options: %w[right left], default: "right" } ]),

    new(key: :service_grid, label: "Grille de services", description: "Liste de prestations en colonnes.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Chapô" } },
        item: { label: "Service", plural: "Services", icon: true,
                fields: { title: { label: "Nom du service" }, body: { label: "Description" },
                          link_url: { label: "Lien" }, link_label: { label: "Libellé du lien" } } },
        settings: [ TONE, { name: :columns, label: "Colonnes", type: :select, options: %w[2 3 4], default: "3" } ]),

    new(key: :cards, label: "Cartes illustrées", description: "Cartes avec image, titre et texte.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Chapô" } },
        item: { label: "Carte", plural: "Cartes", image: true,
                fields: { title: { label: "Titre" }, subtitle: { label: "Sous-titre" },
                          body: { label: "Texte" }, link_url: { label: "Lien" }, link_label: { label: "Libellé du lien" } } },
        settings: [ TONE, { name: :columns, label: "Colonnes", type: :select, options: %w[2 3 4], default: "3" } ]),

    new(key: :stats, label: "Chiffres clés", description: "Arguments chiffrés alignés.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" } },
        item: { label: "Chiffre", plural: "Chiffres",
                fields: { value: { label: "Valeur", hint: "ex. 70 %" }, title: { label: "Légende" }, body: { label: "Précision" } } },
        settings: [ TONE ]),

    new(key: :pricing, label: "Tarifs", description: "Grille tarifaire en lignes prix / prestation.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Mentions" } },
        item: { label: "Ligne de tarif", plural: "Lignes de tarif",
                fields: { title: { label: "Prestation" }, value: { label: "Prix" }, body: { label: "Détail" } } },
        settings: [ TONE ]),

    new(key: :list_columns, label: "Listes en colonnes", description: "Plusieurs familles, chacune avec sa liste.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Chapô" } },
        item: { label: "Famille", plural: "Familles",
                fields: { title: { label: "Nom de la famille" }, body: { label: "Éléments", hint: "Un élément par ligne" } } },
        settings: [ TONE ]),

    new(key: :checklist, label: "Liste d'arguments", description: "Liste à puces mise en valeur.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Chapô" } },
        item: { label: "Argument", plural: "Arguments", fields: { title: { label: "Texte" }, body: { label: "Précision" } } },
        settings: [ TONE ]),

    new(key: :gallery, label: "Galerie", description: "Grille de photos avec agrandissement au clic.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Chapô" } },
        images: :many,
        settings: [ TONE, { name: :columns, label: "Colonnes", type: :select, options: %w[3 4 5], default: "4" } ]),

    new(key: :cta, label: "Appel à l'action", description: "Bloc d'incitation avec boutons.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Texte" } },
        item: { label: "Bouton", plural: "Boutons",
                fields: { title: { label: "Libellé" }, link_url: { label: "Lien" },
                          value: { label: "Style", hint: "principal ou secondaire" } } },
        settings: [ { name: :tone, label: "Ambiance", type: :select, options: %w[dark signal paper], default: "dark" } ]),

    new(key: :banner, label: "Bandeau", description: "Bande étroite pour une information courte.",
        fields: { heading: { label: "Texte" }, body: { label: "Précision" } },
        item: { label: "Bouton", plural: "Boutons", fields: { title: { label: "Libellé" }, link_url: { label: "Lien" } } },
        settings: [ { name: :tone, label: "Ambiance", type: :select, options: %w[signal dark paper], default: "signal" } ]),

    new(key: :brands, label: "Marques", description: "Liste des marques travaillées.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Texte" } },
        item: { label: "Marque", plural: "Marques", image: true,
                fields: { title: { label: "Nom" } } },
        settings: [ TONE ]),

    new(key: :hours, label: "Horaires", description: "Tableau des horaires d'ouverture (source : réglages du site).",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Précision" } },
        settings: [ TONE ]),

    new(key: :contact_info, label: "Coordonnées", description: "Adresse, téléphone et e-mail (source : réglages du site).",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Texte" } },
        settings: [ TONE ]),

    new(key: :contact_panel, label: "Contact : coordonnées + formulaire",
        description: "Une seule bande pour une page contact : coordonnées et horaires à gauche (source : réglages du site), formulaire à droite.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" },
                  subheading: { label: "Chapô", hint: "Affiché au-dessus des deux colonnes" },
                  body: { label: "Texte sous les horaires" } },
        settings: [ TONE, { name: :form_type, label: "Type de formulaire", type: :select,
                            options: %w[contact devis_pneus devis_mecanique], default: "contact" } ]),

    new(key: :map, label: "Carte", description: "Plan d'accès chargé à la demande (source : réglages du site).",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Texte" } },
        settings: [ TONE ]),

    new(key: :form, label: "Formulaire", description: "Insère un formulaire de demande.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" },
                  subheading: { label: "Sous-titre" }, body: { label: "Texte d'introduction" } },
        settings: [ TONE, { name: :form_type, label: "Type de formulaire", type: :select,
                            options: %w[devis_pneus devis_mecanique contact], default: "contact" } ]),

    new(key: :testimonials, label: "Témoignages", description: "Avis clients. À ne remplir qu'avec des avis réellement reçus.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" } },
        item: { label: "Témoignage", plural: "Témoignages",
                fields: { body: { label: "Avis" }, title: { label: "Auteur" }, subtitle: { label: "Contexte" } } },
        settings: [ TONE ]),

    new(key: :google_reviews, label: "Avis Google", description: "Note Google du garage et une sélection d'avis clients. Chaque avis doit être recopié depuis la fiche Google : rien d'inventé.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Chapô" } },
        item: { label: "Avis", plural: "Avis",
                fields: { body: { label: "Avis", hint: "Texte de l'avis, recopié tel quel depuis Google" },
                          title: { label: "Auteur", hint: "Le nom affiché sur Google" },
                          subtitle: { label: "Date", hint: "ex. mars 2026" },
                          value: { label: "Note", hint: "Sur 5, ex. 5 ou 4,5" },
                          link_url: { label: "Lien vers l'avis", hint: "Facultatif" } } },
        settings: [ TONE,
                    { name: :rating, label: "Note globale", hint: "Telle qu'affichée sur Google, ex. 4,6" },
                    { name: :reviews_count, label: "Nombre d'avis", hint: "Le total affiché sur Google, ex. 312" },
                    { name: :profile_url, label: "Lien vers les avis Google",
                      hint: "URL de la fiche Google, onglet Avis" },
                    { name: :columns, label: "Colonnes", type: :select, options: %w[2 3], default: "3" },
                    { name: :visible, label: "Avis affichés", type: :select, options: %w[3 6 9 12 all], default: "9",
                      hint: "Les avis suivants restent enregistrés, ils ne sont simplement pas affichés." } ]),

    new(key: :rich_text, label: "Contenu libre", description: "Texte long : paragraphes, listes et sous-titres.",
        fields: { eyebrow: { label: "Surtitre" }, heading: { label: "Titre" }, body: { label: "Contenu" } },
        settings: [ TONE ])
  ].freeze

  BY_KEY = ALL.index_by(&:key).freeze
  KEYS   = ALL.map(&:key).freeze

  def self.find(key) = BY_KEY[key.to_s]
  def self.fetch(key) = BY_KEY.fetch(key.to_s)
  def self.options_for_select = ALL.map { |k| [ k.label, k.key ] }
end
