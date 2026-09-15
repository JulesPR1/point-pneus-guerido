# Initial content of the CMS, rebuilt from the audit of the existing site
# (see docs/AUDIT.md). Every commercial fact below — prices, packages, opening
# hours, brands, legal notices — is reproduced from the published site.
# Nothing here is invented.
#
# Idempotent: running it again rebuilds the content from scratch.

IMAGES = Rails.root.join("db/seeds/images")

def attach(record, name, filename)
  path = IMAGES.join(filename)
  return puts("  ! image manquante : #{filename}") unless path.exist?

  record.public_send(name).attach(io: path.open, filename: path.basename.to_s)
end

def build_section(page, kind, **attrs)
  items    = attrs.delete(:items) || []
  image    = attrs.delete(:image)
  gallery  = attrs.delete(:gallery)
  settings = attrs.delete(:settings)

  section = page.sections.create!(kind: kind.to_s, settings: settings&.transform_keys(&:to_s), **attrs)
  attach(section, :image, image) if image

  Array(gallery).each do |filename|
    path = IMAGES.join("galerie", filename)
    section.images.attach(io: path.open, filename: filename) if path.exist?
  end

  items.each do |attributes|
    attributes = attributes.dup
    filename = attributes.delete(:image)
    item = section.items.create!(**attributes)
    attach(item, :image, filename) if filename
  end
  section
end

def build_page(**attrs)
  sections = attrs.delete(:sections) || []
  page = Page.create!(**attrs)
  sections.each { |kind, section_attrs| build_section(page, kind, **section_attrs) }
  page
end

puts "Nettoyage…"
[ Section, SectionItem, Page, MediaItem, FormSubmission ].each(&:destroy_all)

# ---------------------------------------------------------------------------
# Administrateur
# ---------------------------------------------------------------------------
admin_email    = ENV.fetch("ADMIN_EMAIL", "admin@point-pneus-guerido.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "changez-ce-mot-de-passe")

admin = AdminUser.find_or_initialize_by(email_address: admin_email)
admin.update!(name: "Administrateur", password: admin_password, password_confirmation: admin_password)
puts "Administrateur : #{admin.email_address}"

# ---------------------------------------------------------------------------
# Réglages du site
# ---------------------------------------------------------------------------

# Mentions légales : un seul texte, dans les réglages du site, ouvert depuis le
# pied de page. Il n'est repris sur aucune page — ni sur contact, ni sous les
# formulaires de devis, où le pavé Bloctel faisait doublon.
LEGAL = <<~TXT.strip
  ## Éditeur du site

  Le site https://www.point-pneus-guerido.com est édité par la société Point Pneus Guerido, SARL au capital de 7 622,45 €, située 9 rue Henri Becquerel, 66330 Cabestany, enregistrée au R.C.S. de Perpignan sous le numéro 450 045 430, TVA FR92450045430.

  La directrice de la publication est FRANCO Marilyne, gérante de l'entreprise. Vous pouvez nous contacter par mail à l'adresse [pointpneusguerido@free.fr](mailto:pointpneusguerido@free.fr) ou par téléphone au 04 68 50 50 68.

  ## Hébergement du site

  Le prestataire des services d'hébergement du site est la société OVH SAS, située au 2 rue Kellermann, 59100 Roubaix.

  ## Liste d'opposition Bloctel

  Tout consommateur ne souhaitant pas faire l'objet de prospection commerciale par voie téléphonique peut s'inscrire gratuitement sur la liste d'opposition au démarchage prévue par l'article L. 223-1 du Code de la consommation. L'inscription peut être effectuée :

  - directement sur le site Bloctel : [bloctel.gouv.fr](https://www.bloctel.gouv.fr/)
  - par courrier postal à l'adresse Société Worldline – Service Worldline, River Ouest 80, Quai Voltaire, 95870 Bezons, France.

  Les consommateurs inscrits sur Bloctel ne pourront faire l'objet d'un démarchage téléphonique par Point Pneus Guerido. L'inscription sur la liste est prise en compte dans un délai maximum de 30 jours à compter de la confirmation reçue par courriel. À compter de cette confirmation, la durée de protection du numéro de téléphone est de 3 ans.

  ## Médiateur de la consommation — Mobilians

  Le médiateur du Conseil national des professions de l'automobile (CNPA) peut vous aider à régler à l'amiable un litige qui vous oppose à un adhérent du CNPA-MOBILIANS.

  Les consommateurs doivent transmettre leurs demandes de médiation :

  - par courrier postal, à l'adresse : M. le Médiateur de Mobilians, 43 bis route de Vaugirard – CS 80016 – 92197 Meudon Cedex
  - par courriel à l'adresse [mediateur@mediateur-mobilians.fr](mailto:mediateur@mediateur-mobilians.fr)
  - sur son site internet : [mediateur-mobilians.fr](https://www.mediateur-mobilians.fr)
TXT

setting = SiteSetting.instance
setting.update!(
  legal_notice: LEGAL,
  company_name: "Point Pneus Guerido",
  tagline: "Le spécialiste en pneu neuf et occasion, à Cabestany, près de Perpignan.",
  phone: "04 68 50 50 68",
  email: "pointpneusguerido@free.fr",
  address_line: "9 rue Henri Becquerel",
  postal_code: "66330",
  city: "Cabestany",
  opening_hours: "Lundi – vendredi|8h – 12h / 14h – 18h30\nSamedi|Fermé",
  map_embed_url: "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3547.453001162379!2d2.92118127654596!3d42.68968091421273!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x12b06f9347bbd4d5%3A0xd679f73cea3277e6!2sPoint%20Pneus%20Guerido!5e1!3m2!1sfr!2sfr!4v1788613203957!5m2!1sfr!2sfr",
  map_link_url: "https://www.google.com/maps/dir/?api=1&destination=Point+Pneus+Guerido%2C+9+rue+Henri+Becquerel%2C+66330+Cabestany",
  # Carte affichée directement, sans bouton : demande du client.
  #
  # L'iframe ci-dessus est une carte Google, qui dépose ses cookies dès le
  # chargement de la page — il faut donc un bandeau de consentement pour être
  # conforme. Deux façons de s'en passer : repasser ce réglage à false, ce qui
  # réactive l'affichage au clic (map_controller.js), ou remplacer map_embed_url
  # par un export OpenStreetMap, qui ne trace personne.
  map_autoload: true,
  default_seo_title: "Point Pneus Guerido",
  default_meta_description: "Vente et montage de pneus neufs et d'occasion, mécanique générale, géométrie 3D, climatisation et rénovation de phares à Cabestany, près de Perpignan."
)
setting.logo.purge if setting.logo.attached?
attach(setting, :logo, "logo.png")
setting.default_og_image.purge if setting.default_og_image.attached?
attach(setting, :default_og_image, "hero-atelier.jpg")


# ---------------------------------------------------------------------------
# Accueil
# ---------------------------------------------------------------------------
puts "Pages…"

build_page(
  title: "Garage pneus et mécanique — Perpignan",
  slug: "accueil", nav_label: "Accueil", home: true, status: :published, position: 0,
  seo_title: "Garage pneus et mécanique — Cabestany, Perpignan",
  meta_description: "Vente et montage de pneus neufs et d'occasion, mécanique générale, géométrie 3D et climatisation à Cabestany (66), près de Perpignan.",
  sections: [
    [ :hero, {
      eyebrow: "Cabestany · Pyrénées-Orientales",
      heading: "Pneus, mécanique et *géométrie 3D*",
      subheading: "Le spécialiste en pneu neuf et occasion. 9 rue Henri Becquerel, à Cabestany (66).",
      body: "Pneus toutes marques, neufs et occasions : l'équilibrage, les valves et le montage sont compris dans le prix annoncé. Au même atelier, mécanique générale, géométrie 3D, recharge de climatisation et rénovation de phares.",
      image: "hero-atelier.jpg",
      items: [
        { title: "Devis pneus gratuit", link_url: "/devis-pneus-perpignan", value: "principal" },
        { title: "Devis mécanique", link_url: "/devis-mecanique", value: "secondaire" }
      ]
    } ],

    [ :service_grid, {
      heading: "Ce que nous faisons, et à quel prix",
      settings: { columns: "3" },
      items: [
        { title: "Centre de montage", icon: "disc-3", body: "Pneus neufs et occasions, tourisme, 4x4 et camionnette. Équilibrage, valves et montage compris dans le prix.", link_url: "/pneus-neuf-reparation", link_label: "Voir la vente de pneus" },
        { title: "Réparation de pneus", icon: "wrench", body: "Vulcanisation à chaud 30 € (tourisme), réparation par mèche 15 €. Occasion contrôlée à partir de 11,00 €.", link_url: "/pneus-doccasion", link_label: "Voir les réparations et les occasions" },
        { title: "Parallélisme / géométrie 3D", icon: "axis-3d", body: "Parallélisme avant 65 €. Avant + arrière et carrossage 85 €, 100 € en 4x4 ou camionnette.", link_url: "/geometrie-3d", link_label: "Voir les tarifs de géométrie" },
        { title: "Mécanique générale", icon: "cog", body: "Freinage, échappement, suspension, embrayage, distribution, vidange, cardans, pompe à eau.", link_url: "/mecanique-garage-automobile", link_label: "Voir les prestations mécaniques" },
        { title: "Recharge climatisation", icon: "thermometer-snowflake", body: "Forfait Clim R134 65 €, forfait R1234Y 130 €. Recharge conseillée tous les 2 ans.", link_url: "/climatisation", link_label: "Voir les forfaits climatisation" },
        { title: "Rénovation de phares", icon: "lamp", body: "Pour les optiques en polycarbonate ternis par les UV, qui ne passent plus au contrôle technique.", link_url: "/renovation-phares", link_label: "Voir la rénovation de phares" }
      ]
    } ],

    [ :text_image, {
      heading: "Pneus : vente et montage",
      body: "Pneus pour toutes marques de véhicules, neufs et occasions. Les pneus d'occasion sont classés en trois catégories selon leur usure et leur marque, et vendus contrôlés.\n\nMontage, équilibrage et parallélisme sont faits sur place.",
      image: "pneus-neufs.jpg",
      settings: { image_side: "right" },
      items: [
        { title: "Tourisme, 4x4 et camionnette" },
        { title: "Pneus été, hiver et toute saison" },
        { title: "Équilibrage, valves et montage compris dans le prix" }
      ]
    } ],

    [ :text_image, {
      heading: "Mécanique générale",
      body: "Entretien et réparation de voitures de toutes marques : freinage, échappement, suspension, embrayage, vidange, prise en charge du contrôle technique, batterie, pompe à eau, équilibrage et parallélisme.",
      image: "mecanique.jpg",
      settings: { image_side: "left" },
      items: [
        { title: "Prise en charge du contrôle technique" },
        { title: "Pose de plaque d'immatriculation" },
        { title: "Garantie pièces et main d'œuvre" }
      ]
    } ],

    [ :checklist, {
      heading: "Nos engagements",
      settings: { tone: "dark" },
      items: [
        { title: "Service rapide et de qualité" },
        { title: "Point Pneus aligne ses prix", body: "Neuf ou occasion, l'équilibrage, les valves et le montage sont compris dans le prix annoncé." },
        { title: "Recyclage des pneus usagés" },
        { title: "Service professionnel", body: "Véhicules de toutes marques, du montage de pneus à la prise en charge du contrôle technique." }
      ]
    } ],

    [ :brands, {
      heading: "Les marques que nous montons",
      body: "Pneus de tourisme, 4x4, camionnette et neige, jantes et accessoires. La disponibilité varie selon la dimension : demandez-nous la vôtre.",
      items: [
        "Michelin", "Goodyear", "Pirelli", "Hankook", "Kleber", "BFGoodrich",
        "Firestone", "Falken", "Nexen", "Cheyen", "Valeo"
      ].map { |name| { title: name } }
    } ],

    [ :cards, {
      heading: "Voir le garage avant de venir",
      settings: { columns: "3" },
      items: [
        { title: "L'atelier en photos", body: "Une cinquantaine de photos de l'accueil, de l'atelier, du stock et d'interventions réelles.", link_url: "/galerie-photos", link_label: "Voir les photos du garage", image: "accueil-boutique.jpg" },
        { title: "Les tarifs de géométrie", body: "Parallélisme avant 65 €, avant + arrière et carrossage 85 €, 100 € en 4x4 ou camionnette.", link_url: "/geometrie-3d", link_label: "Voir les tarifs de géométrie", image: "atelier-jaune.jpg" },
        { title: "Les pièces détachées", body: "Moteur, freinage, direction-suspension-train et électricité : fournies et posées à l'atelier.", link_url: "/nos-pieces-detachees", link_label: "Voir les familles de pièces", image: "comptoir-pieces.jpg" }
      ]
    } ],

    # Avis Google, recopiés mot pour mot depuis la fiche du garage. Ceux que
    # Google tronque derrière « … Plus » ne sont pas repris : on ne termine pas
    # la phrase d'un client.
    #
    # Ce sont des extraits, et le chapô le dit : seuls les avis cinq étoiles ont
    # été recopiés, donc la page ne remplace pas la fiche, elle y renvoie. La
    # note globale et le nombre total d'avis ne sont pas inscrits ici parce
    # qu'ils changent : ils se saisissent au backoffice, relevés sur la fiche
    # le jour où on les saisit, ou ils restent vides et rien ne s'affiche.
    [ :google_reviews, {
      heading: "Avis publiés sur Google",
      body: "Extraits de notre fiche Google, recopiés tels quels. Nous n'avons repris ici que des avis cinq étoiles : la fiche complète, avec la note moyenne et l'ensemble des avis, se consulte sur Google.",
      settings: { tone: "paper", columns: "3", visible: "3",
                  profile_url: "https://www.google.com/maps/place/Point+Pneus+Guerido/@42.6896809,2.9211813,815m/data=!3m1!1e3!4m8!3m7!1s0x12b06f9347bbd4d5:0xd679f73cea3277e6!8m2!3d42.689677!4d2.9237562!9m1!1b1!16s%2Fg%2F1tdhw8vr" },
      items: [
        [ "Saby Lopez", "juin 2026",
          "Équipe au top : competente, sérieuse et aimable. A recommander" ],
        [ "FRANECK", "mai 2026",
          "Idem. rapides, sympas, efficaces, appel au téléphone pour vérifier leur dispo, 10 minutes entre dépose de la voiture et réparation, 15 euros pour remplacer une vis par une mèche, un pneu qui ne fuit plus: excellent rapport qualité/prix. je recommande" ],
        [ "Veronique Venturi", "mai 2026",
          "Très contente du sérieux des employés et du responsable Cedric très compétent dans son travail !!! Je recommande 👌" ],
        [ "Erwan BREDY", "avril 2026",
          "Je recommande à 100% ! Une équipe au top" ],
        [ "Franck", "mars 2026",
          "Enfin un garage de confiance ! On m'a expliqué en détail les réparations nécessaires sans chercher à gonfler la facture. Les tarifs sont très corrects et l'accueil est chaleureux. Vous pouvez y aller les yeux fermés" ],
        [ "Elodie Ramora", "mars 2026",
          "Un garage honnête, où le personnel est toujours agréable et sympathique. Ici on ne profite pas du client, au contraire. Je recommande sans hésiter." ],
        [ "Sml", "février 2026",
          "Rapide, très sympathiques et honnêtes. Gros Big up à Enzo" ],
        [ "Morgane Diaz", "février 2026",
          "Établissement et personnel au top. Gentils, souriants, efficaces, prix corrects et surtout honnêtes !!! Grâce à Enzo, j’ai évité de me faire arnaquer par une autre grande enseigne. Merci pour vos services, je recommande +++." ],
        [ "Mathieu RABELIFERA", "février 2026",
          "accueil excellent, enzo est très patient et efficace, je recommande" ],
        [ "tiserbee", "janvier 2026",
          "Très bon accueil, chaleureux et vraiment à l’écoute ! Je recommande :)" ],
        [ "chlloe k", "décembre 2025",
          "De l’accueil et la manœuvre tout est parfait ! L’équipe est bienveillante, rapide, souriante. Allez-y les yeux fermés!!" ],
        [ "Toni Lucchesi", "novembre 2025",
          "Super service, super personnel (notamment Enzo), et donc forcément super garage ! Je recommande à tous !" ],
        [ "Anastasia Gaillard", "septembre 2025",
          "Très satisfaite de ma visite : accueil chaleureux, personnel serviable et à l’écoute, prix raisonnables et rendez-vous obtenu rapidement. Je recommande ce garage." ],
        [ "freddy Istiry", "août 2025",
          "Service exceptionnel, accueil et réparation. A recommander Equipe rapide , professionnelle et très accueillante.Ils ont pris le temps de m'expliquer et de faire la réparation efficacement. Je recommande vivement cet endroit à tous ceux qui cherchent un service honnête et de qualité. Merci encore" ],
        [ "Gwendoline Lamblin", "août 2025",
          "Que dire à part un grand merci de nous avoir dépanné ce matin, après avoir fait 800 km avec un montage de pneus réalisé la veille dans notre région vite fait mal fait qui aurait pu compromettre nos vacances. Une prise en charge rapide et efficace. Je recommande vivement." ],
        [ "Jeff Thery", "août 2025",
          "Problème de valves just avant de reprendre la route, arrivé 15 minutes avant fermeture, résultat deux valves changées et pas voulu que l’on règle ! Il y a encore des gens comme ça ! Et d’une gentillesse à ttes épreuves ! Encore merci à vous !!" ],
        [ "Aurelie Loursel", "août 2025",
          "Super garage, toutes les compétences réunis pour l'entretien du véhicule, une vraie prise en compte du client et des prix très concurrentiels merci à Cédric et son équipe." ],
        [ "Philppe Eeckhout", "août 2025",
          "Tardivement je laisse un avis, mais à chaque fois très bon accueil et de très bons services. Très sympa 🤓" ],
        [ "Océane Leroux", "juillet 2025",
          "Je suis arrivée avec un pneu crevé et j’ai été prise en charge immédiatement, sans rendez-vous, contrairement à d’autres garages qui demandaient d’attendre plusieurs jours. Le service a été rapide, efficace et à un tarif très raisonnable. Pro et réactif, merci à Enzo :)" ],
        [ "Luciano VAGNARELLI", "juillet 2025",
          "Super garage avec un service au top ! J’ai été accueilli avec professionnalisme et bienveillance. Travail rapide, soigné et à des tarifs honnêtes. Mention spéciale à Enzo pour son sérieux et son engagement ! Je recommande les yeux fermés. 💪🚗" ],
        [ "Jean-Ghislain Fortuny", "juillet 2025",
          "Je me suis présenté sans rendez-vous en urgence pour un problème de valve de pneu défectueuse. Le délai d'attente et d'intervention a été beaucoup plus court qu'annoncé, intervention très pro, vraiment un excellent service, merci 😊" ],
        [ "David Gimenez", "juillet 2025",
          "Service rapide, prestations de qualité. Les prix sont raisonnables et une équipe très professionnelle ! Je conseille !" ],
        [ "carole brument", "juin 2025",
          "Bonjour, j’ai eu l’occasion de m’y rendre aujourd’hui pour un parallélisme pour ma voiture, très bonne équipe, efficace et encore merci au responsable pour le geste commercial. Je reviendrai et je recommande. 😉👍" ],
        [ "MARC FONTEYNE", "avril 2025",
          "bonne accueil rapidité de la prestation et prix trés raisonnable avec en + savoir faire et compétences qui sont présente merci à CEDRIC" ],
        [ "Rambolitaine", "novembre 2024",
          "Travail rapide et efficace Accueil immédiat et le mécano n’a absolument pas cherché à nous faire de survente. Il est appréciable d’avoir des personnes honnêtes - Je recommande" ],
        [ "Prose Lady", "mai 2024",
          "Bonjour, cela fait des années que je viens dans ce garage, j'ai toujours été bien accueillie. Il y a toujours plus de monde mais ils essayent de vous trouver un moment pour vous satisfaire et jusqu'à présent avec le sourire. Merci." ],
        [ "François LECOMTE", "août 2023",
          "Crevaisons pendant les vacances. A deux jours du départ vers le nord. Hyper rapide, pro et courtois. Je recommande vivement cet atelier. Bonne continuation à vous et merci Enzo ;-)" ],
        [ "Dalila", "janvier 2023",
          "Nous sommes ravis de leur travail, rapidité et gentillesse!!! Beaucoup de personnel, nous n’avons pratiquement pas attendu. Nous les recommandons vivement, merci!" ],
        [ "Bruno Salvaing", "octobre 2022",
          "Bonjour, un pneu changé en 15 mn, sans rdv, (c'est difficile à gérer une crevaison), 30€, c'est une petite voiture. Impeccable." ]
      ].map { |author, date, body| { title: author, subtitle: date, value: "5", body: body } }
    } ]
  ]
)

# ---------------------------------------------------------------------------
# Pneumatiques
# ---------------------------------------------------------------------------
build_page(
  title: "Vente de pneus neufs et d'occasion",
  slug: "pneus-neuf-reparation", nav_label: "Vente pneus", status: :published, position: 1,
  seo_title: "Vente de pneus neufs et d'occasion — Perpignan",
  meta_description: "Pneus neufs et d'occasion de tourisme, 4x4 et camionnette. Équilibrage, valves et montage inclus. Réparation par vulcanisation à chaud ou mèche.",
  sections: [
    [ :hero, {
      heading: "Vente de pneus neufs et d'occasion",
      subheading: "Des prix exceptionnels sur les pneus de tourisme, de 4x4 et de camionnette.",
      body: "Découvrez notre offre de pneus d'occasion à prix discount sur toutes les grandes marques et équipez-vous à petit prix de pneumatiques été et hiver pour votre véhicule. Découvrez aussi toute la gamme de nos pneus neufs.",
      image: "pneus-neufs.jpg",
      items: [ { title: "Demander un devis pneus", link_url: "/devis-pneus-perpignan", value: "principal" } ]
    } ],

    [ :rich_text, {
      heading: "Ce qui est compris dans le prix",
      body: "Dans notre prix sont inclus l'équilibrage, les valves et le montage.\n\nPour les pneus d'occasion, la remise s'applique sur le prix des pneus neufs, dans la limite des stocks disponibles et des prix pratiqués dans notre garage."
    } ],

    [ :pricing, {
      heading: "Tarifs de réparation",
      settings: { tone: "dark" },
      items: [
        { title: "Vulcanisation à chaud", value: "30 €", body: "Voiture de tourisme." },
        { title: "Réparation par mèche", value: "15 €" },
        { title: "Autres véhicules", value: "Nous consulter", body: "Nous contacter pour les tarifs." }
      ]
    } ],

    [ :cta, {
      heading: "Demander un devis pneus",
      body: "La dimension se lit sur le flanc du pneu, par exemple 205/55 R16 91 V. Indiquez-la dans le formulaire : nous répondons avec un prix monté, équilibré, valves comprises.",
      settings: { tone: "signal" },
      items: [ { title: "Devis pneus", link_url: "/devis-pneus-perpignan", value: "principal" } ]
    } ]
  ]
)

build_page(
  title: "Réparation de pneus et pneus d'occasion",
  slug: "pneus-doccasion", nav_label: "Réparation pneus", status: :published, position: 2,
  seo_title: "Réparation de pneus et pneus d'occasion — Cabestany",
  meta_description: "Réparations conformes aux procédures des Professionnels du Pneu, marquage REP, et trois catégories de pneus d'occasion contrôlés.",
  sections: [
    [ :hero, {
      heading: "Réparation de pneus et pneus d'occasion",
      subheading: "Réparer plutôt que jeter : c'est économique, et c'est écologique.",
      image: "vulcanisation.jpg"
    } ],

    [ :rich_text, {
      heading: "La conformité des réparations",
      body: "Les réparations des dommages causés aux pneus font partie des opérations indispensables en terme économique, mais aussi écologique, en réduisant d'autant les déchets.\n\nBien entendu, tous les pneus endommagés ne sont pas réparables. Seuls des spécialistes peuvent juger de la faisabilité de la réparation ; elle sera alors faite selon des procédures bien établies. Ces procédures sont détaillées dans les manuels des fournisseurs de produits de réparation et dans un ouvrage édité par les Professionnels du Pneu.\n\nDepuis le 1er janvier 2008, les réparations par vulcanisation à chaud sont identifiées par un marquage « REP » à la verticale du bouchon de gomme vulcanisé. Les réparations autorisées sur les flancs sont alors plus facilement identifiables."
    } ],

    [ :checklist, {
      heading: "Trois catégories de pneus d'occasion",
      body: "Les différents contrôles permettent de proposer à la vente des pneus de :",
      settings: { tone: "dark" },
      items: [
        { title: "Catégorie 1", body: "Faible usure, état neuf, grande marque." },
        { title: "Catégorie 2", body: "Faible usure, état neuf, autre marque." },
        { title: "Catégorie 3", body: "Usure 50 %, à partir de 11,00 €." }
      ]
    } ],

    [ :cta, {
      heading: "Faire contrôler vos pneus",
      body: "Le contrôle visuel se fait à l'atelier, sans rendez-vous. Pour savoir si votre dimension est disponible en occasion, appelez-nous : le stock varie.",
      items: [
        { title: "Nous appeler", link_url: "tel:+33468505068", value: "principal" },
        { title: "Nous écrire", link_url: "/contact", value: "secondaire" }
      ]
    } ]
  ]
)

# ---------------------------------------------------------------------------
# Entretiens (rubrique + sous-pages)
# ---------------------------------------------------------------------------
entretiens = build_page(
  title: "Entretien et mécanique",
  slug: "entretiens", nav_label: "Entretiens", status: :published, position: 3,
  seo_title: "Entretien et mécanique automobile — Cabestany",
  meta_description: "Mécanique générale, pièces détachées, rénovation de phares et décalaminage moteur dans notre atelier de Cabestany.",
  sections: [
    [ :hero, {
      heading: "Entretien et mécanique",
      subheading: "Au-delà du pneumatique, les services du garage traditionnel : quatre pages détaillent ce que nous faisons.",
      image: "comptoir-pieces.jpg"
    } ],
    [ :service_grid, {
      heading: "Nos prestations d'entretien",
      settings: { columns: "2" },
      items: [
        { title: "Mécanique : garage automobile", icon: "wrench", body: "Entretien, vidange, embrayage, distribution, échappement, cardans, freins et suspension.", link_url: "/mecanique-garage-automobile", link_label: "Voir les prestations mécaniques" },
        { title: "Nos pièces détachées", icon: "cog", body: "Moteur, direction-suspension-train, freinage et électricité : le détail des familles de pièces.", link_url: "/nos-pieces-detachees", link_label: "Voir les familles de pièces" },
        { title: "Rénovation phares", icon: "lamp", body: "Redonner sa transparence à un optique en polycarbonate terni par les UV.", link_url: "/renovation-phares", link_label: "Voir la rénovation de phares" },
        { title: "Décalaminage moteur", icon: "spray-can", body: "Nettoyage de la calamine, vannes EGR et filtres à particules compris.", link_url: "/decalaminage-moteur", link_label: "Voir le décalaminage" }
      ]
    } ],
    [ :cta, {
      heading: "Demander un devis mécanique",
      body: "Cochez les interventions souhaitées et décrivez le véhicule. Le devis est gratuit et sans engagement.",
      settings: { tone: "dark" },
      items: [ { title: "Devis mécanique", link_url: "/devis-mecanique", value: "principal" } ]
    } ]
  ]
)

build_page(
  title: "Mécanique : garage automobile",
  slug: "mecanique-garage-automobile", nav_label: "Mécanique : garage automobile",
  status: :published, position: 0, parent: entretiens,
  seo_title: "Mécanique et garage automobile — Cabestany, Perpignan",
  meta_description: "Entretien, vidange, embrayage, distribution, échappement, cardans, freins et suspension : tous les services du garage traditionnel.",
  sections: [
    [ :hero, {
      heading: "Les services du garage traditionnel",
      subheading: "En plus de la vente de pneus et de pièces détachées, nous vous proposons tous les services du garage traditionnel.",
      image: "mecanique.jpg"
    } ],
    [ :checklist, {
      heading: "Entretien et réparation",
      items: [
        { title: "Entretien" }, { title: "Vidange" }, { title: "Embrayage" },
        { title: "Distribution" }, { title: "Échappement" }, { title: "Les cardans" }
      ]
    } ],
    [ :checklist, {
      heading: "Les organes de sécurité que nous prenons en charge",
      settings: { tone: "dark" },
      items: [
        { title: "Freinage", body: "Disques et tambours, plaquettes et mâchoires, étriers, flexibles, kits de frein." },
        { title: "Suspension et direction", body: "Amortisseurs, triangles de suspension, rotules de direction, roulements de roue, cardans." },
        { title: "Pneumatiques", body: "Montage, équilibrage, valves, parallélisme et géométrie." },
        { title: "Éclairage", body: "Projecteurs, feux arrière, et rénovation des optiques en polycarbonate ternis." }
      ]
    } ],
    [ :cta, {
      heading: "Demander un devis mécanique",
      body: "Indiquez l'intervention et le véhicule : nous chiffrons les pièces et la main d'œuvre.",
      settings: { tone: "signal" },
      items: [ { title: "Demander un devis", link_url: "/devis-mecanique", value: "principal" } ]
    } ]
  ]
)

build_page(
  title: "Nos pièces détachées",
  slug: "nos-pieces-detachees", nav_label: "Nos pièces détachées",
  status: :published, position: 1, parent: entretiens,
  seo_title: "Pièces détachées automobiles — Cabestany",
  meta_description: "Pièces moteur, direction-suspension-train, freinage et électricité : les familles de pièces détachées que nous fournissons et posons.",
  sections: [
    [ :hero, {
      heading: "Nos pièces détachées",
      subheading: "Fournies et posées à l'atelier, avec garantie pièces et main d'œuvre.",
      image: "comptoir-pieces.jpg"
    } ],
    [ :list_columns, {
      heading: "Quatre familles de pièces",
      items: [
        { title: "Pièces moteur", body: "Kit d'embrayage\nKit de distribution\nBougie de préchauffage\nFiltre à carburant\nFiltre à air\nTout le moteur" },
        { title: "Direction, suspension, train", body: "Amortissement\nTriangle de suspension\nRoulement de roue\nCardan\nRotule de direction\nToute la direction-suspension-train" },
        { title: "Freinage", body: "Disques / tambours\nPlaquettes / mâchoires\nKit de frein\nÉtrier de frein\nFlexible de frein\nTout le freinage" },
        { title: "Électricité", body: "Mécanisme de lève-vitre\nFeu arrière\nAlternateur\nProjecteur principal\nDémarreur\nToute l'électricité" }
      ]
    } ],
    [ :cta, {
      heading: "Commander une pièce",
      body: "Donnez-nous la marque, le modèle et l'immatriculation du véhicule : c'est ce qui permet d'identifier la référence exacte.",
      settings: { tone: "dark" },
      items: [ { title: "Devis mécanique", link_url: "/devis-mecanique", value: "principal" } ]
    } ]
  ]
)

build_page(
  title: "Rénovation de phares",
  slug: "renovation-phares", nav_label: "Rénovation phares",
  status: :published, position: 2, parent: entretiens,
  seo_title: "Rénovation d'optiques de phares — Cabestany",
  meta_description: "Les optiques en polycarbonate ternissent et ne passent plus au contrôle technique depuis 2010. La rénovation coûte 70 % de moins qu'un optique neuf.",
  sections: [
    [ :hero, {
      heading: "Rénovation d'optiques de phares",
      subheading: "Redonner sa transparence à un optique en polycarbonate terni, plutôt que le remplacer.",
      image: "renovation-phares.jpg"
    } ],
    [ :rich_text, {
      heading: "Pourquoi un phare se ternit",
      body: "Depuis quelques années, les optiques de phare sont conçus à partir de polycarbonate, un matériau plastique offrant de meilleures performances que le verre en terme de résistance aux impacts.\n\nCependant, le polycarbonate a tendance à se détériorer rapidement. En effet, nous constatons bien souvent que ces optiques se ternissent, blanchissent ou jaunissent sous l'effet des U.V. et des différentes intempéries en l'espace de deux à trois ans.\n\nD'autre part, les lavages successifs provoquent micro-rayures et opacité."
    } ],
    [ :rich_text, {
      heading: "Ce que cela change",
      settings: { tone: "dark" },
      body: "Un optique terni diffuse la lumière au lieu de la projeter : selon l'état du polycarbonate, la perte de vision nocturne annoncée va de 30 à 40 %.\n\nDepuis le 1er janvier 2010, l'état des optiques fait partie des points vérifiés au contrôle technique : un phare trop terni entraîne une contre-visite. Nous rénovons l'optique existant. Selon le véhicule et l'état de l'optique, l'opération revient nettement moins cher qu'un optique neuf — de l'ordre de 70 % d'économie sur les modèles courants. Passez à l'atelier : nous vous dirons si l'optique est récupérable, et à quel prix, avant toute intervention."
    } ],
    [ :cta, {
      heading: "Faire contrôler vos optiques",
      body: "Un passage à l'atelier suffit pour savoir si la rénovation est possible.",
      items: [
        { title: "Nous appeler", link_url: "tel:+33468505068", value: "principal" },
        { title: "Nous écrire", link_url: "/contact", value: "secondaire" }
      ]
    } ]
  ]
)

build_page(
  title: "Décalaminage moteur",
  slug: "decalaminage-moteur", nav_label: "Décalaminage moteur",
  status: :published, position: 3, parent: entretiens,
  seo_title: "Décalaminage moteur DKBOOST — Cabestany",
  meta_description: "Plus de 70 % des véhicules souffrent de problèmes dus à la calamine. Le décalaminage DKBOOST nettoie sans agressivité, y compris vannes EGR et FAP.",
  sections: [
    [ :hero, {
      heading: "Décalaminage moteur",
      subheading: "Nettoyer la calamine déposée dans le moteur, sans le démonter."
    } ],
    [ :rich_text, {
      heading: "Comment cela fonctionne",
      body: "La calamine est un résidu charbonneux généré par la combustion des gaz. Elle se dépose sur les parois des cylindres, les sièges des soupapes et les pistons, et finit par encrasser la vanne EGR et le filtre à particules.\n\nNous utilisons le procédé DKBOOST ©, qui sublime la calamine : elle passe de l'état solide à l'état gazeux et part par l'échappement. Le moteur n'est pas démonté. Le fabricant annonce plus de 70 % des véhicules concernés par des problèmes liés à la calamine ; c'est son chiffre, pas un relevé fait dans notre atelier.\n\nLe décalaminage n'est pas un remède universel : il agit sur l'encrassement, pas sur une pièce défectueuse. Dites-nous le modèle, le kilométrage et les symptômes, nous vous dirons s'il est indiqué."
    } ],

    [ :cta, {
      heading: "Savoir si le décalaminage est indiqué",
      body: "Perte de puissance, fumée, voyant moteur : décrivez-nous les symptômes et le kilométrage.",
      settings: { tone: "signal" },
      items: [ { title: "Nous contacter", link_url: "/contact", value: "principal" } ]
    } ]
  ]
)

# ---------------------------------------------------------------------------
# Climatisation & géométrie
# ---------------------------------------------------------------------------
build_page(
  title: "Recharge de climatisation automobile",
  slug: "climatisation", nav_label: "Climatisation", status: :published, position: 4,
  seo_title: "Recharge de climatisation automobile — Cabestany",
  meta_description: "Forfait Clim 65 € (R134) et 130 € (R1234Y) : contrôle de température, tirage du circuit, réinjection de gaz et contrôle du système.",
  sections: [
    [ :hero, {
      heading: "Recharge de climatisation",
      subheading: "Forfait R134 65 €, forfait R1234Y 130 €. Le gaz utilisé dépend de l'année du véhicule."
    } ],
    [ :rich_text, {
      heading: "Une vérification régulière s'impose",
      body: "La climatisation crée les conditions d'une attention qui n'est pas perturbée par la température extérieure.\n\nVotre climatisation est à vérifier tous les ans et à faire recharger tous les 2 ans. Le filtre d'habitacle est à changer tous les ans."
    } ],
    [ :checklist, {
      heading: "Les signes qui doivent alerter",
      settings: { tone: "dark" },
      items: [
        { title: "Une baisse d'efficacité du refroidissement" },
        { title: "Des problèmes d'allergies", body: "Éternuements, toux, irritations lors de l'utilisation de la climatisation." },
        { title: "De mauvaises odeurs", body: "Elles se dégagent à l'intérieur de l'habitacle dès sa mise en route." }
      ]
    } ],
    [ :pricing, {
      heading: "Nos forfaits climatisation",
      body: "Le forfait Recharge climatisation comprend : le contrôle de la température de l'habitacle, le tirage du circuit de climatisation, la réinjection de gaz dans le circuit et le contrôle du bon fonctionnement du système.\n\nOffre réservée aux particuliers et non cumulable avec d'autres promotions en cours. Photos non contractuelles.",
      items: [
        { title: "Forfait Clim R134", value: "65 €" },
        { title: "Forfait Clim R1234Y", value: "130 €" }
      ]
    } ],
    [ :cta, {
      heading: "Prendre rendez-vous pour la climatisation",
      body: "Prévoyez le passage avant l'été : c'est la période où les délais s'allongent.",
      settings: { tone: "signal" },
      items: [
        { title: "Nous appeler", link_url: "tel:+33468505068", value: "principal" },
        { title: "Nous écrire", link_url: "/contact", value: "secondaire" }
      ]
    } ]
  ]
)

build_page(
  title: "Parallélisme et géométrie 3D",
  slug: "geometrie-3d", nav_label: "Géométrie 3D", status: :published, position: 5,
  seo_title: "Parallélisme et géométrie 3D — Cabestany, Perpignan",
  meta_description: "Contrôle et réglage de la géométrie : parallélisme avant 65 €, avant + arrière et carrossage 85 €, 4x4 ou camionnette 100 €.",
  sections: [
    [ :hero, {
      eyebrow: "Trains roulants",
      heading: "Parallélisme et géométrie 3D",
      subheading: "Il est indispensable de faire contrôler la géométrie de votre véhicule au moins une fois par an.",
      image: "atelier-jaune.jpg"
    } ],
    [ :rich_text, {
      heading: "Ce que fait le réglage",
      body: "Le contrôle et le réglage de la géométrie consistent à optimiser tous les angles et alignements réglables sur votre véhicule, en conformité avec les données du constructeur et l'analyse des usures des pneumatiques.\n\n## Une géométrie déréglée entraîne\n\n- Une usure rapide et anormale de vos pneus\n- Une usure prématurée des éléments de direction\n- Une tenue de route aléatoire"
    } ],
    [ :checklist, {
      heading: "Ce que vous y gagnez",
      settings: { tone: "dark" },
      items: [
        { title: "Moins d'usure du pneumatique" },
        { title: "Meilleure tenue de route et de cap" },
        { title: "Meilleur confort de conduite" },
        { title: "Optimisation de la consommation de carburant" }
      ]
    } ],
    [ :pricing, {
      heading: "Nos tarifs de géométrie",
      items: [
        { title: "Parallélisme avant", value: "65 €", body: "Voiture." },
        { title: "Parallélisme avant + train arrière et carrossage", value: "85 €", body: "Voiture." },
        { title: "Train avant + train arrière et carrossage", value: "100 €", body: "4x4 ou camionnette." }
      ]
    } ],
    [ :cta, {
      heading: "Prendre rendez-vous pour une géométrie",
      body: "Une usure des pneus d'un seul côté, un volant décentré ou une voiture qui tire sont les signes d'une géométrie à contrôler.",
      items: [ { title: "Prendre rendez-vous", link_url: "/contact", value: "principal" } ]
    } ]
  ]
)

# ---------------------------------------------------------------------------
# Devis
# ---------------------------------------------------------------------------
devis = build_page(
  title: "Devis gratuits",
  slug: "devis", nav_label: "Devis gratuits", status: :published, position: 6,
  seo_title: "Devis pneus et mécanique gratuits — Cabestany",
  meta_description: "Deux formulaires de devis gratuits et sans engagement : l'un pour les pneus, l'autre pour la mécanique et l'entretien.",
  sections: [
    [ :hero, {
      heading: "Devis gratuits",
      subheading: "Deux formulaires, selon que votre besoin concerne les pneumatiques ou la mécanique."
    } ],
    [ :cards, {
      heading: "Choisissez votre formulaire",
      settings: { columns: "2" },
      items: [
        { title: "Devis pneus", body: "Type, gamme, dimensions et véhicule : nous chiffrons le pneu monté.", link_url: "/devis-pneus-perpignan", link_label: "Remplir le formulaire", image: "pneus-neufs.jpg" },
        { title: "Devis mécanique", body: "Freinage, distribution, embrayage, révision, vidange et plus encore.", link_url: "/devis-mecanique", link_label: "Remplir le formulaire", image: "mecanique.jpg" }
      ]
    } ]
  ]
)

build_page(
  title: "Devis pneus",
  slug: "devis-pneus-perpignan", nav_label: "Devis pneus",
  status: :published, position: 0, parent: devis,
  seo_title: "Devis pneus gratuit — Perpignan, Cabestany",
  meta_description: "Devis pneus gratuit : type, gamme, dimensions et véhicule. Le prix annoncé comprend le montage, l'équilibrage et les valves.",
  sections: [
    [ :hero, {
      eyebrow: "Devis gratuit",
      heading: "Devis pneus",
      subheading: "Les dimensions se lisent sur le flanc du pneu, par exemple 205/55 R16 91 V."
    } ],
    [ :form, { heading: "Votre demande de devis pneus",
               settings: { form_type: "devis_pneus", tone: "paper" } } ]
  ]
)

build_page(
  title: "Devis mécanique",
  slug: "devis-mecanique", nav_label: "Devis mécanique",
  status: :published, position: 1, parent: devis,
  seo_title: "Devis mécanique et entretien gratuit — Cabestany",
  meta_description: "Demandez votre devis mécanique : freinage, distribution, embrayage, échappement, révision, vidange, pompe à eau.",
  sections: [
    [ :hero, {
      eyebrow: "Devis gratuit",
      heading: "Devis mécanique",
      subheading: "Cochez les interventions souhaitées et décrivez votre véhicule."
    } ],
    [ :form, { heading: "Votre demande de devis mécanique",
               settings: { form_type: "devis_mecanique", tone: "paper" } } ]
  ]
)

# ---------------------------------------------------------------------------
# Galerie & contact
# ---------------------------------------------------------------------------
gallery_files = Dir.children(IMAGES.join("galerie")).sort

build_page(
  title: "Le garage en photos",
  slug: "galerie-photos", nav_label: "En photos", status: :published, position: 7,
  seo_title: "Galerie photos du garage — Cabestany",
  meta_description: "L'atelier, le stock de pneus, le comptoir de pièces détachées et nos interventions en images.",
  sections: [
    [ :hero, {
      heading: "Le garage en photos",
      subheading: "L'atelier, le stock, le comptoir et quelques interventions."
    } ],
    [ :gallery, {
      heading: "Galerie",
      settings: { columns: "4" },
      gallery: gallery_files
    } ]
  ]
)

build_page(
  title: "Contact",
  slug: "contact", nav_label: "Contact", status: :published, position: 8,
  seo_title: "Contact — Point Pneus Guerido, Cabestany",
  meta_description: "Point Pneus Guerido, 9 rue Henri Becquerel, 66330 Cabestany. Téléphone 04 68 50 50 68. Ouvert du lundi au vendredi.",
  sections: [
    [ :hero, {
      eyebrow: "Cabestany (66)",
      heading: "Nous contacter",
      subheading: "Pour toute demande d'informations, le plus simple reste de nous appeler.",
      items: [ { title: "04 68 50 50 68", link_url: "tel:+33468505068", value: "principal" } ]
    } ],
    # Coordonnées, horaires et formulaire dans une seule bande : le formulaire
    # attendait jusqu'ici en cinquième position, deux mille pixels plus bas.
    [ :contact_panel, {
      heading: "Nous écrire, ou passer nous voir",
      subheading: "Une question sur une prestation, une disponibilité, un délai ? Écrivez-nous. Pour un besoin urgent, le téléphone reste le plus rapide.",
      settings: { form_type: "contact" }
    } ],
    [ :map, { heading: "Plan d'accès", body: "9 rue Henri Becquerel, 66330 Cabestany.", settings: { tone: "dark" } } ]
  ]
)

# ---------------------------------------------------------------------------
# Bibliothèque de médias : les visuels réutilisables
# ---------------------------------------------------------------------------
puts "Bibliothèque de médias…"
{
  "hero-atelier.jpg"       => "Rayonnages de pneus neufs dans l'atelier",
  "pneus-neufs.jpg"        => "Pneus neufs prêts au montage",
  "pneu-repare.jpg"        => "Pneu réparé par vulcanisation",
  "vulcanisation.jpg"      => "Réparation vulcanisée vue de l'intérieur du pneu",
  "comptoir-pieces.jpg"    => "Comptoir des pièces détachées",
  "atelier-jaune.jpg"      => "Stock de pneus et pont de l'atelier",
  "mecanique.jpg"          => "Espace mécanique du garage",
  "renovation-phares.jpg"  => "Optique de phare rénové",
  "accueil-boutique.jpg"   => "Espace d'accueil du garage"
}.each do |filename, alt|
  media = MediaItem.new(title: filename.sub(/\.\w+\z/, "").humanize, alt_text: alt)
  attach(media, :file, filename)
  media.save!
end

puts <<~SUMMARY

  Terminé.
    #{Page.count} pages (#{Page.published.count} publiées), #{Section.count} sections,
    #{SectionItem.count} éléments, #{MediaItem.count} médias.

    Backoffice : /admin
    Identifiant : #{admin.email_address}
    Mot de passe : #{admin_password == 'changez-ce-mot-de-passe' ? 'changez-ce-mot-de-passe (à changer !)' : '(défini via ADMIN_PASSWORD)'}
SUMMARY
