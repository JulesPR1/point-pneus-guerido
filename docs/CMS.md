# Le mini-CMS

## 1. Modèle de données

```
SiteSetting  (ligne unique)   coordonnées, horaires, logo, SEO par défaut, carte
AdminUser    ──< Session      authentification du backoffice

Page         ──< Section ──< SectionItem
  │                └── image (Active Storage)          ── image
  │                └── images (galerie)
  └── og_image

MediaItem                      bibliothèque d'images réutilisables
FormSubmission                 demandes reçues (type, payload JSON, statut, notes)
```

`Page` porte le slug, le statut, la place dans le menu (`position`, `show_in_nav`, `parent_id`)
et les champs SEO. Une page est un **conteneur de sections ordonnées** : elle n'a aucune colonne
propre à un type de contenu, donc rien à migrer pour ajouter une nouvelle mise en page.

## 2. Les sections

`SectionKind` (`app/models/section_kind.rb`) déclare les types disponibles. Chaque entrée décrit :

- les champs utilisés (`eyebrow`, `heading`, `subheading`, `body`) et leur libellé ;
- s'il y a une image, plusieurs, ou aucune ;
- s'il y a des éléments répétables, et quels champs ils utilisent ;
- les réglages proposés : soit une liste fermée (`tone`, `columns`, `image_side`, `form_type`),
  soit un champ libre (`rating`, `reviews_count`, `profile_url`).

Le formulaire du backoffice, la validation et la liste des réglages autorisés sont **dérivés de
cette déclaration**. Ajouter un type se fait en deux gestes :

1. ajouter une entrée dans `SectionKind::ALL` ;
2. créer `app/views/sections/_<clé>.html.erb`.

Aucune migration, aucune modification de `Page` ou de `Section`.

Un réglage à liste fermée doit contenir une des valeurs déclarées ; un réglage libre est écourté
à 300 caractères, et un réglage dont le nom finit par `_url` passe le même contrôle qu'un lien
d'élément (`SafeUrl`) — un `javascript:` saisi au backoffice n'atteint jamais une page publique.

Types livrés : hero, texte + image, grille de services, cartes illustrées, chiffres clés, tarifs,
listes en colonnes, liste d'arguments, galerie, appel à l'action, bandeau, marques, horaires,
coordonnées, carte, formulaire, témoignages, avis Google, contenu libre.

### Avis Google

Le type `google_reviews` affiche la note Google du garage et une sélection d'avis. Il ne parle
à aucune API : Google ne laisse pas rejouer ses avis librement, l'API Places n'en rend que cinq
et exige une clé facturée. Tout est donc saisi au backoffice, ce qui a l'avantage de laisser
choisir les avis mis en avant.

| Où | Quoi |
|---|---|
| Réglage `rating` | la note globale telle qu'affichée sur Google, ex. `4,6` |
| Réglage `reviews_count` | le nombre total d'avis, ex. `312` |
| Réglage `profile_url` | lien vers la fiche Google, onglet Avis |
| Un élément par avis | `body` l'avis, `title` l'auteur, `subtitle` la date, `value` la note sur 5, `link_url` le permalien (facultatif) |
| Réglage `visible` | combien d'avis sont affichés (3, 6, 9, 12, tous) — les autres restent enregistrés |

`4,6` et `4.6` sont acceptés indifféremment ; une note illisible n'affiche simplement pas
d'étoiles. Le bandeau de note et la grille d'avis s'affichent indépendamment : une section
sans aucun avis saisi montre la note et le lien, une section sans note montre les avis.

**Les avis doivent être recopiés depuis la fiche Google, mot pour mot.** Un faux avis est une
pratique commerciale trompeuse ; le seed n'en pré-remplit donc aucun.

### Ordre

`Positionable` gère l'ordre en base (`position`). Le backoffice propose le glisser-déposer
(`sortable_controller.js`, `PATCH …/reorder`) **et** des flèches monter/descendre qui
fonctionnent sans JavaScript. Le site public trie en SQL.

### Mise en forme du texte

Les champs `body` acceptent une syntaxe volontairement minuscule, échappée avant tout traitement :

| Écriture | Rendu |
|---|---|
| ligne vide | nouveau paragraphe |
| `- texte` | puce |
| `## Titre` | sous-titre |
| `**gras**` | gras |
| `[libellé](https://…)` | lien (schémas `http(s)`, `/`, `#`, `mailto:`, `tel:` uniquement) |
| `*mot*` dans un titre de hero | mot mis en avant en jaune |

## 3. Les formulaires

`FormDefinition` (`app/models/form_definition.rb`) décrit les trois formulaires publics
(devis pneus, devis mécanique, contact) : groupes, champs, types, options, obligations,
longueurs maximales.

La même déclaration sert à :

1. **rendre** le formulaire public (`shared/_public_form`, `shared/_form_field`) ;
2. **filtrer** la requête — seules les clés déclarées sont conservées ;
3. **valider** côté serveur dans `FormSubmission` — présence, format e-mail et téléphone,
   longueur, appartenance aux options proposées, refus de toute clé inattendue ;
4. **afficher** la demande dans le backoffice avec les bons libellés, dans le bon ordre.

Une soumission valide crée un `FormSubmission` (`form_type`, `payload`, `status`, date).
Le nom, l'e-mail et le téléphone sont recopiés en colonnes pour la liste et la recherche.
Statuts : nouveau → en cours → traité → archivé.

Protections : jeton CSRF, limitation à 8 envois par 10 minutes et par IP, champ piège
(honeypot), aucune donnée réaffichée sans échappement.

### La carte

`SiteSetting` porte l'URL d'iframe, le lien d'itinéraire et un interrupteur
`map_autoload` (« Afficher la carte directement, sans bouton »), utilisé par la section « Carte »
et par le pied de page :

- **activé** (par défaut) : l'iframe est dans le HTML, la carte est simplement là. C'est le bon
  réglage pour OpenStreetMap, qui ne dépose aucun cookie ;
- **désactivé** : l'iframe n'est insérée qu'au clic (`map_controller.js`), donc un visiteur qui ne
  demande pas le plan n'envoie aucune requête au fournisseur. À garder avec une carte **Google
  Maps**, dont l'iframe dépose des cookies dès l'affichage et demande donc un consentement.

## 4. Images

Active Storage avec libvips. Les variantes sont déclarées sur les modèles
(`thumb`, `card`, `wide`, `og`) et servies en WebP. Les vues posent systématiquement
`loading="lazy"`, `decoding="async"` et les dimensions intrinsèques quand l'analyse du blob
les a fournies, pour éviter les décalages de mise en page.

Le type de fichier est vérifié à partir du **contenu réel** du fichier, pas de l'en-tête
déclaré par le navigateur.
