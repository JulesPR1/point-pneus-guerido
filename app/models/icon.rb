# The icon library the back-office picks from.
#
# The drawings are Lucide (https://lucide.dev, ISC licence), copied verbatim
# into vendor/icons/lucide by `bin/rails icons:import`. Nothing is redrawn here:
# adding an icon means naming it in a group below and re-running the task, so
# the catalogue and the files on disk can never drift apart.
#
# Only the inner markup of each file is used — IconsHelper rebuilds the <svg>
# wrapper — so every icon keeps the same 24×24 box, the same stroke weight and
# currentColor whatever the pack version.
class Icon
  DIRECTORY = Rails.root.join("vendor/icons/lucide")
  DEFAULT   = "wrench"

  Entry = Data.define(:name, :label, :group)

  # Name → label shown in the picker. Grouped so the picker stays readable:
  # a garage is looking for "climatisation", not for "thermometer-snowflake".
  GROUPS = {
    "Pneus et roues" => {
      "circle-dot" => "Pneu",
      "disc-3" => "Roue / jante",
      "circle-dashed" => "Bande de roulement",
      "disc-2" => "Disque",
      "gauge" => "Pression",
      "circle-gauge" => "Manomètre",
      "ruler-dimension-line" => "Dimension",
      "axis-3d" => "Géométrie 3D",
      "move-horizontal" => "Parallélisme",
      "compass" => "Alignement",
      "target" => "Carrossage",
      "crosshair" => "Centrage",
      "waves" => "Adhérence",
      "rotate-cw" => "Permutation",
      "snowflake" => "Pneu hiver",
      "sun" => "Pneu été",
      "cloud-snow" => "Neige",
      "recycle" => "Recyclage"
    },
    "Véhicules" => {
      "car" => "Voiture",
      "car-front" => "Voiture de face",
      "car-taxi-front" => "Taxi",
      "truck" => "Camionnette",
      "caravan" => "Caravane",
      "bus" => "Bus",
      "bike" => "Deux-roues",
      "tractor" => "Tracteur",
      "trailer" => "Remorque",
      "forklift" => "Chariot élévateur",
      "key-round" => "Clé de contact",
      "fuel" => "Carburant",
      "rectangle-horizontal" => "Plaque d'immatriculation"
    },
    "Atelier et mécanique" => {
      "wrench" => "Clé à molette",
      "hammer" => "Marteau",
      "drill" => "Perceuse",
      "cog" => "Engrenage",
      "settings-2" => "Ajustements",
      "bolt" => "Boulon",
      "nut" => "Écrou",
      "hard-hat" => "Sécurité atelier",
      "construction" => "Travaux",
      "factory" => "Atelier",
      "ruler" => "Mesure",
      "scan-line" => "Diagnostic",
      "scan-search" => "Contrôle",
      "radar" => "Détection",
      "activity" => "Test",
      "disc" => "Freinage",
      "move-vertical" => "Suspension",
      "spline" => "Échappement",
      "zap" => "Électricité",
      "battery" => "Batterie",
      "battery-charging" => "Recharge batterie",
      "plug-zap" => "Démarrage",
      "droplet" => "Vidange",
      "droplets" => "Liquides",
      "spray-can" => "Nettoyage",
      "paint-roller" => "Peinture",
      "brush" => "Polissage",
      "sparkles" => "Rénovation"
    },
    "Confort et éclairage" => {
      "wind" => "Ventilation",
      "fan" => "Ventilateur",
      "air-vent" => "Aération",
      "thermometer" => "Température",
      "thermometer-snowflake" => "Climatisation",
      "thermometer-sun" => "Chauffage",
      "lightbulb" => "Ampoule",
      "lamp" => "Phare / optique",
      "flashlight" => "Éclairage",
      "sun-medium" => "Luminosité",
      "eye" => "Visibilité",
      "glasses" => "Contrôle visuel"
    },
    "Confiance et garantie" => {
      "shield" => "Protection",
      "shield-check" => "Garantie",
      "shield-half" => "Sécurité",
      "badge-check" => "Certifié",
      "check" => "Coche",
      "check-check" => "Double coche",
      "circle-check-big" => "Validé",
      "clipboard-check" => "Contrôle technique",
      "clipboard-list" => "Check-list",
      "file-check" => "Document validé",
      "file-text" => "Document",
      "notebook-pen" => "Devis",
      "stamp" => "Tampon",
      "award" => "Récompense",
      "medal" => "Médaille",
      "trophy" => "Trophée",
      "thumbs-up" => "Satisfaction",
      "handshake" => "Accord",
      "heart-handshake" => "Confiance",
      "users" => "Équipe",
      "user-check" => "Client suivi"
    },
    "Prix et commerce" => {
      "euro" => "Prix",
      "banknote" => "Paiement",
      "coins" => "Tarif",
      "wallet" => "Budget",
      "credit-card" => "Carte bancaire",
      "receipt" => "Facture",
      "tag" => "Étiquette",
      "tags" => "Promotions",
      "percent" => "Remise",
      "calculator" => "Estimation",
      "shopping-cart" => "Panier",
      "shopping-bag" => "Achat",
      "store" => "Boutique",
      "package" => "Forfait",
      "package-check" => "Commande prête",
      "boxes" => "Stock",
      "layers" => "Gamme",
      "grid-2x2" => "Assortiment",
      "list-checks" => "Prestations"
    },
    "Délais et rendez-vous" => {
      "clock" => "Horaires",
      "clock-3" => "Durée",
      "timer" => "Rapidité",
      "calendar" => "Calendrier",
      "calendar-check" => "Rendez-vous",
      "calendar-clock" => "Créneau",
      "hourglass" => "Attente",
      "rocket" => "Intervention rapide"
    },
    "Contact et accès" => {
      "phone" => "Téléphone",
      "phone-call" => "Appel",
      "smartphone" => "Mobile",
      "mail" => "E-mail",
      "send" => "Envoyer",
      "message-circle" => "Message",
      "headset" => "Assistance",
      "map-pin" => "Adresse",
      "map" => "Plan",
      "navigation" => "Itinéraire",
      "route" => "Trajet"
    },
    "Lieux et environnement" => {
      "building-2" => "Bâtiment",
      "warehouse" => "Entrepôt",
      "house" => "Accueil",
      "leaf" => "Écologie",
      "trees" => "Environnement",
      "globe" => "International"
    },
    "Repères" => {
      "info" => "Information",
      "circle-help" => "Aide",
      "triangle-alert" => "Attention",
      "bell" => "Alerte",
      "star" => "Étoile",
      "arrow-right" => "Flèche",
      "external-link" => "Lien externe",
      "download" => "Téléchargement",
      "search" => "Recherche",
      "x" => "Fermer",
      "image" => "Image",
      "inbox" => "Boîte de réception",
      "settings" => "Réglages",
      "layout-grid" => "Tableau de bord"
    }
  }.freeze

  ALL = GROUPS.flat_map { |group, icons|
    icons.map { |name, label| Entry.new(name: name, label: label, group: group) }
  }.freeze

  BY_NAME = ALL.index_by(&:name).freeze
  NAMES   = ALL.map(&:name).freeze

  # Order matters: the first keyword found in the item's title wins. Only used
  # when no icon was picked in the back-office, so an old item still gets a
  # sensible drawing instead of a hole.
  KEYWORDS = [
    [ %w[clim froid gaz r134 r1234], "thermometer-snowflake" ],
    [ %w[parallel equilibr geometrie alignement carrossage train], "axis-3d" ],
    [ %w[pneu montage roue jante gomme], "circle-dot" ],
    [ %w[phare optique eclairage ampoule], "lamp" ],
    [ %w[plaque immatricul], "credit-card" ],
    [ %w[frein disque plaquette], "disc" ],
    [ %w[vidange huile decalaminage calamine], "droplet" ],
    [ %w[batterie electric demarr alternateur], "battery" ],
    [ %w[garantie qualite confiance securite], "shield-check" ],
    [ %w[choix assortiment stock piece gamme], "layers" ],
    [ %w[controle technique diagnostic devis], "clipboard-check" ],
    [ %w[rapide delai rendez horaire], "clock" ],
    [ %w[prix tarif forfait budget], "euro" ],
    [ %w[recyclage environnement], "recycle" ],
    [ %w[mecanique atelier reparation entretien], "wrench" ]
  ].freeze

  class << self
    def exist?(name) = BY_NAME.key?(name.to_s)
    def find(name)   = BY_NAME[name.to_s]
    def label(name)  = find(name)&.label

    # The inner markup of the SVG file, without its <svg> wrapper.
    def body(name)
      bodies[name.to_s] || bodies.fetch(DEFAULT)
    end

    # Best guess from a free-text label, for items saved before the picker
    # existed (or left empty on purpose).
    def guess(text, fallback: DEFAULT)
      haystack = fold(text)
      match = KEYWORDS.find { |words, _| words.any? { |word| haystack.include?(word) } }
      match ? match.last : fallback
    end

    # "Parallélisme" → "parallelisme", so the keyword table stays ASCII.
    def fold(text)
      text.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase
    end

    private
      def bodies
        @bodies ||= NAMES.to_h { |name| [ name, extract(DIRECTORY.join("#{name}.svg")) ] }.freeze
      end

      def extract(path)
        path.read[/<svg\b[^>]*>(.*)<\/svg>/m, 1].to_s.gsub(/\s+/, " ").strip
      end
  end
end
