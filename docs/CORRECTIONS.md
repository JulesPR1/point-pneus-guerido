# Passe de correction éditoriale — 15 septembre 2026

Relecture du site au regard de `rapport-correction.md`. L'objet n'était pas de changer
l'habillage : la charte, la typographie et les composants sont ceux de `DESIGN.md`. Ce qui a
changé, ce sont les affirmations, la structure des pages et les quelques endroits où le code
imposait un discours.

Règle appliquée partout : **toute phrase qui n'a pas de source dans `AUDIT.md` et que le garage
ne peut pas défendre a été retirée ou reformulée.** Rien n'a été inventé pour combler un trou.

## 1. Affirmations retirées

| Affirmation retirée | Où | Pourquoi |
|---|---|---|
| « Réponse sous 48 h ouvrées » | sous le bouton des trois formulaires, meta de `/devis` | Aucun délai n'a été communiqué par le garage, et surtout rien ne le tient : une demande est écrite en base et relue au backoffice, aucun e-mail n'est envoyé. La note dit maintenant ce qui se passe réellement, et donne le téléphone pour l'urgent. |
| « testés par une entreprise agréée » (pneus d'occasion) | accueil | Certification par un tiers, non sourcée. |
| « faible usure, entre 0 et 15 % » | accueil | Absent de l'audit, et en contradiction avec la catégorie 3 du site source (usure 50 %). |
| « Profitez de nos promotions pour votre achat de pneu » | accueil, bloc marques | Promotion annoncée sans promotion affichée. |
| « tout est fait dans le même atelier, par la même équipe. Vous déposez la voiture, vous n'avez pas à courir d'un garage à l'autre » | accueil, chapô des services | Écrit à la reprise, pas dans la source. Le fait défendable — un seul atelier, une seule adresse — est passé dans le hero. |
| Descriptions du garage : « Un espace d'attente au comptoir de l'atelier », « Neufs et occasions, toutes dimensions » | accueil, cartes | Écrites à la reprise pour remplir trois cartes. |
| « Venez comme vous êtes », « Trois bonnes raisons », « Ce sur quoi vous pouvez compter » | accueil | Titres de remplissage. |
| Section « Pourquoi nous choisir ? » en entier | accueil | Trois cartes d'adjectifs (« large assortiment », « pièces de qualité », « garantie totale ») vraies de n'importe quel garage. Le seul fait vérifiable, la garantie pièces et main d'œuvre, a rejoint le bloc mécanique. |
| Crédit « Site créé par Tanak International Ltd » | pied de page | `AUDIT.md` prévoyait de le conserver. Le site ayant été refait, le maintenir attribuerait la refonte à un auteur qui ne l'a pas faite. La décision de l'audit a été corrigée. |

## 2. Affirmations conservées mais conditionnées

| Affirmation | Traitement |
|---|---|
| « 70 % moins cher que le remplacement d'un optique neuf » | N'est plus un grand chiffre isolé. Passée en texte, rattachée à ce qui la conditionne (« selon le véhicule et l'état de l'optique », « sur les modèles courants ») et suivie de la seule chose vérifiable par le visiteur : passer à l'atelier pour savoir si l'optique est récupérable, et à quel prix. |
| « perte de vision nocturne de 30 à 40 % » | Présentée comme une fourchette annoncée, dépendante de l'état du polycarbonate, dans le corps du texte. |
| « plus de 70 % des véhicules concernés par la calamine » | Attribuée explicitement au fabricant du procédé, et non au garage : « c'est son chiffre, pas un relevé fait dans notre atelier ». La page dit aussi ce que le décalaminage **ne** fait **pas**. |
| Contrôle technique depuis le 01/01/2010 | Conservé tel que le site source l'affirme. Aucune source externe n'a été ajoutée : en inventer une aurait été pire que de ne pas en avoir. |
| Avis Google | Voir §3. |

## 3. Les avis Google

Les 29 avis restent en base, recopiés mot pour mot. Ce qui change :

- **3 avis affichés** au lieu de 9. Un mur d'éloges cinq étoiles se lit comme un décor, pas comme
  une preuve.
- **Le chapô dit ce qui a été fait** : ce sont des extraits, seuls des avis cinq étoiles ont été
  repris, et la fiche complète — avec la note moyenne et l'ensemble des avis — est sur Google. Le
  bouton « Lire tous les avis » y mène.
- **La note globale et le nombre d'avis restent vides.** Ils ne sont pas connus à la date de cette
  passe, et ils changent. Ils se saisissent au backoffice, relevés sur la fiche le jour de la
  saisie ; tant qu'ils sont vides, rien ne s'affiche.

## 4. Structure des pages

- **Accueil : 10 sections → 8.** Suppression de « Pourquoi nous choisir ? » et du bloc d'appel à
  l'action final, qui répétait pour la quatrième fois les deux mêmes boutons (hero, en-tête, barre
  mobile). Les trois cartes du bas mènent maintenant à trois destinations différentes et portent
  chacune une information : le nombre de photos, les trois tarifs de géométrie, les quatre familles
  de pièces.
- **Grille de services : des prix, pas des adjectifs.** Chaque service affiche ce qu'il coûte quand
  le prix est public (30 € / 15 € en réparation, 65 € en parallélisme, 65 € / 130 € en
  climatisation, 11,00 € en occasion).
- **Grilles de pictogrammes remplacées par du contenu.** « Votre sécurité est primordiale »
  (4 icônes, aucun texte) est devenue quatre postes décrits : ce que recouvre le freinage, la
  suspension, les pneumatiques, l'éclairage. Les trois catégories de pneus d'occasion, qui sont une
  comparaison et non trois produits, sont passées de trois cartes à pictogramme à une liste.
- **Chiffres clés décoratifs supprimés** sur la rénovation de phares et le décalaminage (voir §2).
- **Logos de marques retirés.** Les onze fichiers font 35 px de haut : agrandis ils sont flous, et
  un bandeau de logos suggère un partenariat qui n'est pas documenté. Les onze noms restent, en
  texte — ce que `AUDIT.md` avait d'ailleurs décidé.
- **Titres d'accroche en astérisques** (`Pneus, mécanique et *géométrie 3D*`) : le mécanisme est
  conservé, mais utilisé sur le seul hero d'accueil. Répété sur douze pages, c'était un tic.

## 5. Appels à l'action

Les onze blocs d'appel à l'action posaient une question rhétorique (« Vos pneus s'usent d'un seul
côté ? », « Votre moteur manque de souffle ? », « Un doute sur l'état de vos pneus ? »). Chacun
nomme désormais l'action, et l'information utile qui était dans la question est passée dans le
corps du texte. Même chose pour les libellés de liens : « Voir la page » × 4 sur la page
Entretiens est devenu « Voir les prestations mécaniques », « Voir les familles de pièces », etc.

## 6. Code

- `_hero.html.erb` — le bandeau adresse / téléphone / horaires ne s'affiche plus que sur l'accueil.
  Il est déjà dans la barre supérieure, le pied de page et la page contact ; répété sous chaque
  hero, il n'informait plus.
- `_cards.html.erb`, `_service_grid.html.erb` — un lien sans libellé reprend le titre de l'élément
  au lieu de retomber sur « Découvrir » / « En savoir plus ».
- `_public_form.html.erb` — note de bas de formulaire réécrite (voir §1).
- `_footer.html.erb` + `ApplicationHelper#legal_page` — lien « Mentions légales » dans le pied de
  page, vers la page qui les porte, ou rien si elle est dépubliée.
- `application.css` — suppression de l'entrée échelonnée du hero (six `animation-delay`).
- **Carte** — le chargement au clic avait d'abord été mis par défaut, l'iframe Google déposant
  ses cookies dès l'ouverture de n'importe quelle page. Le client a demandé la carte affichée
  directement : le réglage `map_autoload` est repassé à `true`, et le site a donc besoin d'un
  bandeau de consentement pour être conforme (voir §10). Les deux comportements restent
  disponibles depuis le backoffice et chacun a son test système ; le chemin « au clic » était
  d'ailleurs couvert par un test qui échouait depuis l'origine, faute d'être piloté par le
  réglage plutôt que par la valeur par défaut.

## 7. Fontes, composants et effets

Deuxième passe, sur ce qui relevait du gabarit plutôt que du texte.

**Fontes — trois familles → deux.** Instrument Serif (italique) était déclarée pour exactement
deux sélecteurs : le sous-titre de carte, qu'aucune carte n'utilisait, et la citation de la section
« Témoignages », que le site ne rend pas puisqu'il affiche des avis Google. Quatre fichiers WOFF2
livrés pour un effet d'accent jamais vu. Famille, fichiers et token `--font-accent` retirés.
Restent Archivo (titres, étiquettes) et Instrument Sans (texte courant) — ni l'une ni l'autre du
fonds Inter / Geist / Sora / Outfit / Manrope / DM Sans / Plus Jakarta / Space Grotesk, et les deux
avec un repli système.

**Étiquettes en capitales très espacées.** Le symptôme était réparti sur onze règles, avec cinq
valeurs d'interlettrage différentes (0,04 · 0,06 · 0,07 · 0,10 · 0,12 em). Un seul token,
`--tracking-label: 0.04em`, les remplace. Et les capitales ont été retirées là où elles se
battaient avec le contenu : jours d'ouverture, dates d'avis, titres de familles de pièces, libellés
de la barre d'action mobile, lien « Voir l'avis sur Google ».

**Surtitres : 28 → 5.** Le composant imposait une case à remplir au-dessus de chaque titre, et
elle l'était avec un synonyme du titre : « MARQUES » au-dessus de « Les marques que nous montons »,
« OPTIQUES » au-dessus de « Rénovation d'optiques de phares », « FORMULAIRE » au-dessus de « Votre
demande de devis pneus ». Ne restent que ceux qui disent ce que le titre ne dit pas : le lieu
(accueil, contact), la catégorie technique (« Trains roulants »), la gratuité (« Devis gratuit »).

**Pastilles d'icônes.** Chaque tuile de grille portait un carré jaune de 44 px derrière son
pictogramme. L'icône aide à repérer un service parmi six et reste ; le carré de couleur, qui
décorait chaque carte sans rien dire, part. L'icône est posée nue, en gris d'encre.

**Halo du hero.** `radial-gradient` blanc à 7 % « pour que le noir ne soit pas à plat » : retiré.

**Zoom au survol des cartes** (`scale(1.03)`) : retiré, l'ombre portait déjà l'affordance. Celui
de la galerie reste — c'est la seule marque de survol d'une vignette et il annonce le clic.

**Ce qui a été vérifié et laissé en place :** aucun glassmorphism, aucun fond flou, aucun dégradé
violet/bleu, aucune particule, aucun blob, aucun grain, aucun compteur animé, aucune révélation au
défilement (`docs/DESIGN.md` en décrivait une qui n'avait jamais été écrite — le paragraphe est
corrigé). Le seul dégradé restant est le chevron d'un `<select>`, dessiné en CSS.
`prefers-reduced-motion` neutralise toujours transitions et animations.

## 8. Page contact et mentions légales

**Le bouton d'itinéraire disparaissait au mauvais moment.** Le lien « Ouvrir l'itinéraire » était
placé dans le message de consentement de la carte. `map_controller.js` retire ce message en
insérant l'iframe : le seul lien qui menait réellement au garage s'effaçait donc à la seconde où
le visiteur venait de dire qu'il cherchait son chemin. Il est maintenant hors du cadre, en bouton
principal, et il survit à l'affichage de la carte. Un test système le vérifie.

Au passage, la section « Carte » fonctionne enfin sur fond sombre : la plaque et le texte du
message de consentement n'étaient redits que pour le pied de page, si bien qu'un `tone: dark`
donnait un message gris sur gris.

**Le formulaire de contact attendait en cinquième position.** La page enchaînait hero,
coordonnées, horaires, carte, formulaire, mentions — six bandes, le formulaire à deux mille
pixels du haut. Nouveau type de section `contact_panel` : coordonnées et horaires à gauche,
formulaire à droite, une seule bande juste après le hero. La colonne de gauche est épinglée sur
grand écran, de sorte que le téléphone reste sous les yeux pendant la saisie. La page passe de
six bandes à trois.

**Les mentions légales sont regroupées dans une boîte de dialogue du pied de page.** Elles
étaient une section de la page contact, et le pavé Bloctel était en plus recopié sous les deux
formulaires de devis. Elles vivent désormais dans le champ `legal_notice` des réglages du site —
une colonne qui existait en base, était déjà autorisée par le contrôleur, mais n'apparaissait
dans aucun formulaire du backoffice et n'était affichée nulle part. Un seul texte, un seul
endroit où le corriger, accessible de toutes les pages et d'aucune autre. La boîte est un
`<dialog>` natif : focus piégé, Échap, arrière-plan inerte, rien à réimplémenter. Sans
JavaScript, le lien du pied de page reste un lien d'ancre et `:target` affiche le texte dans le
flux. La page contact s'appelle maintenant « Contact » tout court.

## 9. Tests ajoutés

- le bandeau pratique du hero n'apparaît que sur l'accueil ;
- un lien sans libellé reprend le titre de l'élément, jamais « Découvrir » ;
- la note des formulaires ne promet aucun délai et donne le téléphone ;
- les mentions légales s'ouvrent depuis le pied de page, et n'apparaissent qu'une fois dans le
  site ; sans texte saisi, le lien du pied de page disparaît ;
- la boîte de dialogue s'ouvre au clic et se ferme avec Échap ;
- le bouton d'itinéraire survit à l'affichage de la carte ;
- le panneau de contact pose le formulaire à côté des coordonnées, et ne rend le chapô qu'une fois ;
- une page chargée des sections les plus bavardes (prix, marques, avis, listes de pièces) ne
  déborde pas horizontalement en 390 px.

`bin/rails test` : 29 tests. `bin/rails test:system` : 11 tests. `bin/rubocop` et `bin/brakeman`
sans signalement.

## 10. À trancher avec le garage

Ces points ne peuvent pas être réglés depuis le code — ils demandent une information que seul le
garage détient.

1. **Les deux listes de marques du site source ne concordent pas.** Le texte « Qui sommes-nous ?.. »
   citait Michelin, Bridgestone, Firestone, Hankook, Hanksugi, Wanli, Goodyear, Continental, Nova ;
   le bandeau de logos donnait Michelin, Goodyear, Pirelli, Hankook, Kleber, BFGoodrich, Firestone,
   Falken, Nexen, Cheyen, Valeo. Le site retient la seconde. À confirmer, et à réduire aux marques
   réellement montées aujourd'hui.
2. **Bandeau de consentement aux cookies.** La carte Google est affichée directement, à la
   demande du client : son iframe dépose des cookies dès le chargement de chaque page, sans que
   le visiteur ait rien demandé. Trois issues possibles — ajouter un bandeau de consentement,
   remplacer l'embed par un export OpenStreetMap (qui ne trace personne), ou décocher « Afficher
   la carte directement » au backoffice pour revenir au chargement au clic.
3. **Note Google et nombre d'avis** : à relever sur la fiche et à saisir au backoffice, ou à
   laisser vides.
4. **Délai de réponse aux demandes** : si le garage veut en annoncer un, il faut d'abord qu'une
   demande lui parvienne autrement qu'en se connectant au backoffice. Aucune notification n'est
   envoyée aujourd'hui.
5. **Mot de passe administrateur** : le seed pose `changez-ce-mot-de-passe`. À changer avant toute
   mise en ligne.
