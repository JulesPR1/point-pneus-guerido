# Direction artistique & design system

## 1. Le concept : « le garage de quartier, bien tenu »

Point Pneus Guerido est un atelier réel : des racks de pneus, un tableau de tarifs au mur, des gens
qu'on connaît. Le site doit ressembler à ça — pas à une landing page SaaS, pas non plus à une
démonstration de style graphique.

La direction a été recalée sur les sites de garages indépendants qui vieillissent bien
(référence de travail : [autodeutsche.co.uk](https://autodeutsche.co.uk)) : une mise en page
sobre, des cartes blanches lisibles, des boutons pleins et carrés d'angles adoucis, de vraies
photos de l'atelier, et **une** couleur d'accent qui fait tout le travail.

**Tonalité** : direct, concret, professionnel — le ton d'un devis clair.
**Ce dont on se souvient** : le jaune du logo, les photos de l'atelier, et le fait qu'on trouve
le numéro de téléphone en trois secondes sur n'importe quelle page.

Ce qui a été explicitement retiré parce que ça sonnait « gabarit généré » : le bandeau de danger
jaune-noir en diagonale, les numéros de section en gouttière (`01`, `02`, `03`), la numérotation
des tuiles de service, les boutons à ombre-tampon décalée, et les libellés en capitales
très espacées partout.

## 2. Typographie

| Rôle | Police | Pourquoi |
|---|---|---|
| Titres, signalétique, chiffres | **Archivo** (variable, `wdth` 100→125, `wght` 400→800) | Grotesque de signalétique, très haute en capitales, chasses larges disponibles ; parfaite pour un titre d'atelier |
| Texte courant, interface | **Instrument Sans** | Humaniste, chaleureuse, excellente en petit corps — apporte le « local et humain » |
| Accents éditoriaux, citations, chiffres mis en avant | **Instrument Serif** (italique) | Une seule respiration éditoriale par page ; évite le ton purement technique |

Les trois familles sont **auto-hébergées** en WOFF2 (sous-ensembles `latin` + `latin-ext`,
`font-display: swap`) : aucune requête vers un CDN tiers, pas d'exposition RGPD.

Échelle fluide en `clamp()`, de `--step--1` à `--step-5`. Une seule taille par niveau,
jamais de titre géant sans hiérarchie : `h1` culmine à `--step-5`, `h2` à `--step-3`,
`h3` à `--step-1`.

## 3. Couleurs

Héritées du logo (jaune signalétique sur noir), retravaillées pour être tenables sur un site entier.

Les gris sont **strictement neutres** : dès qu'ils tirent sur le chaud, l'ensemble se lit comme
un thème beige et le jaune perd son statut d'accent.

```
--ink-900   #101112   noir — fonds sombres, texte principal
--ink-800   #17181A
--ink-700   #232528   graphite — surfaces sombres secondaires
--steel-500 #6B7075   texte secondaire sur clair
--paper-300 #D8DBDE   bordures visibles (cartes, tableaux)
--paper-100 #F1F2F4   chrome du backoffice, survols
--paper-050 #F8F9FA   en-têtes de tableaux, surfaces très légères
--white     #FFFFFF   fond de page et fond des cartes
--signal    #FFD400   jaune — accent, jamais en aplat de fond de page
--signal-700 #C9A400  variante foncée du jaune (surtitres, focus)
--alert     #B3341C   erreurs, champs obligatoires
--ok        #2E6A4A   confirmations
```

**Le fond de page est blanc.** L'ambiance `paper` — celle par défaut de toute section — rend donc
du blanc ; le rythme d'une page vient des bandes `dark` et `signal`, pas d'une alternance de
teintes claires.

Le jaune reste un **accent** : bouton principal, surtitre, pastille d'icône, mot mis en avant
dans un titre de hero, filet de 4 px. Jamais de dégradé, jamais de verre dépoli.
Le blanc pur (`--white`) porte l'en-tête et les cartes ; `--paper-100` reste le fond de page.

## 4. Trame et espacement

- Grille de 12 colonnes, conteneur `1240px`, gouttières fluides.
- Échelle d'espacement sur base 4 px (`--space-1` = 4 px → `--space-14` = 128 px).
- Rythme vertical des sections : `clamp(56px, 8vw, 112px)`.
- Pas de gouttière de numérotation : le contenu part du bord gauche du conteneur, sur toute la
  largeur disponible. Les têtes de section sont plafonnées à `44rem` pour rester lisibles.

## 5. Rayons, filets, ombres

Rayons doux mais discrets : `--radius-1: 3px` (filets, focus), `--radius-2: 6px`
(boutons, champs, pastilles), `--radius-3: 10px` (cartes, photos), pilule réservée aux badges
et aux pastilles de coche.

Les ombres sont **douces et courtes**, jamais décoratives :
`--shadow-sm` pose une carte sur le fond, `--shadow-lift` la soulève au survol,
`--shadow-card` sert aux surfaces plus importantes (formulaire). Les séparations restent des
filets de 1 px.

## 6. Composants

`.btn` (`--primary`, `--ghost`, `--on-dark`, `--quiet`, `--danger`, tailles `--lg`/`--sm`) ·
`.field` + `.input` + `.select` + `.textarea` · `.choice` (radio/case à cocher en tuile tactile) ·
`.card` (photo + corps) · `.tile` (pastille d'icône + titre + lien) · `.tile__icon` ·
`.badge` (`--new`, `--in_progress`, `--handled`, `--archived`) ·
`.eyebrow` · `.rule--accent` · `.price-row` (conducteur pointillé) ·
`.icon-picker` (bibliothèque d'icônes du back-office) · `.toast` · `.stat` · `.hours-table` · `.gallery` · `.site-nav` / `.drawer` · `.pagination` · `.flash`.

**Boutons** : aplat de couleur, bord adouci, libellé en casse normale. La hiérarchie passe par la
couleur (jaune = action principale, blanc bordé = action secondaire, contour clair sur fond noir),
pas par l'épaisseur du trait. Au survol, seul le fond change.

**Icônes** (`Icon` + `IconsHelper`) : la bibliothèque [Lucide](https://lucide.dev) (licence ISC),
copiée telle quelle dans `vendor/icons/lucide` par `bin/rails icons:import`. Le catalogue proposé au
back-office est déclaré dans `Icon::GROUPS` : ajouter une icône, c'est la nommer dans un groupe puis
relancer la tâche. Seul l'intérieur du fichier SVG est repris ; le `<svg>` est reconstruit par
`icon_tag`, donc toutes les icônes gardent la même boîte 24×24, la même graisse de trait et
`currentColor`, et se posent dans la pastille jaune. Chaque service d'une grille choisit son icône
dans le sélecteur du back-office (recherche insensible aux accents, aperçu immédiat) ; laissé vide,
le champ retombe sur une déduction à partir du titre (« climatisation » → thermomètre flocon,
« parallélisme » → géométrie 3D, …).

Chaque composant existe **une seule fois** ; les variations passent par un modificateur, pas par
une nouvelle règle locale.

**Messages flash** : sur le site public, un résultat de formulaire s'affiche en `.toast`
(`toast_controller.js`) — une carte flottante, bord fin, ombre courte, icône verte ou rouge selon le
type, bouton de fermeture. Elle glisse depuis le bas, attend six secondes, puis s'en va seule ; le
survol, le focus clavier et le glissement latéral suspendent ou avancent ce délai. Rien ne bouge
dans la page pendant la lecture, contrairement à la bande `.flash` poussée dans le flux. Placement :
au-dessus de la barre d'actions mobile sur petit écran, en bas à droite à partir de 64rem. Le
back-office garde la bande `.flash` : c'est un outil, l'information y reste au fil du contenu.

## 7. Interactions

- Une seule orchestration à l'arrivée : révélation échelonnée du hero (`animation-delay`).
- Apparition des sections au défilement via `animation-timeline: view()`, sous `@supports`,
  avec un état final visible par défaut : sans support, rien ne casse.
- Survols : changement de fond sur les boutons, passage de `--shadow-sm` à `--shadow-lift` sur
  les cartes, léger zoom de la photo, flèche du lien qui avance de 3 px. Rien ne se déplace
  sous le curseur.
- `:focus-visible` toujours visible : contour jaune de 2 px avec 2 px d'offset.
- `@media (prefers-reduced-motion: reduce)` neutralise toutes les transitions et animations.

## 8. Responsive

Mobile-first. Points de rupture : `40rem`, `52rem`, `64rem`, `80rem`, `100rem`.

- Menu mobile : tiroir plein écran, entrées de 56 px, fermeture au `Échap` et au clic extérieur,
  focus piégé, `inert` sur le reste de la page.
- Barre d'action fixe en bas d'écran sur mobile : **Appeler** / **Devis gratuit**.
- Formulaires : un champ par ligne sous 40rem, `font-size: 16px` minimum (pas de zoom iOS),
  `inputmode` et `autocomplete` renseignés, radios et cases à cocher en tuiles de 48 px.
- Grille tarifaire : le conducteur pointillé disparaît sous 40rem, le prix passe sous la prestation.

## 9. Le backoffice

Même jeu de tokens, mais un autre métier : un outil utilisé toutes les semaines, pas une vitrine.
La règle est donc la sobriété.

- **Chrome** : barre latérale noire fixe (`--ink-900`), zone de travail sur `--paper-100`,
  panneaux blancs à bord `--paper-300` et ombre courte.
- **Navigation** : deux groupes libellés (*Contenu*, *Atelier*), une icône par entrée, l'élément
  courant sur fond `--ink-700` avec son icône en jaune. Le compteur de demandes à traiter est la
  seule pastille jaune de la barre.
- **Jaune** : réservé à l'action principale d'un écran (enregistrer, créer) et aux compteurs qui
  disent « quelque chose vous attend ». Les actions de ligne dans une liste sont neutres
  (`.btn--ghost`), sans quoi une liste de dix pages affiche dix boutons jaunes.
- **Tableaux** : en-tête collant, une ligne par enregistrement, cellule d'actions sur une seule
  ligne — une cellule d'actions qui passe à la ligne double la hauteur de chaque ligne.
- **Formulaires** : largeur plafonnée à `56rem`, libellés en casse normale, barre d'actions
  collante en bas de la page.

## 10. Accessibilité

Contrastes vérifiés AA (`--signal` n'est utilisé comme fond qu'avec du texte `--ink-900`,
ratio 13,4:1). Lien d'évitement, points de repère ARIA, `aria-current` sur la navigation,
hiérarchie H1 → H2 → H3 imposée par les gabarits de section, `alt` administrable pour
chaque image, erreurs de formulaire reliées aux champs par `aria-describedby` et annoncées
par un résumé `role="alert"`.
