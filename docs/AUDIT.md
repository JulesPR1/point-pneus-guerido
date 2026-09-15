# Audit du site existant — point-pneus-guerido.com

> Audit **strictement en lecture seule** (GET uniquement). **Aucun formulaire n'a été soumis.**
> Méthode : `curl` sur les URLs publiques listées dans `sitemap.xml`, puis extraction hors-ligne
> du texte, des titres, des métadonnées, des formulaires et des médias.

## 1. Technique de l'existant

| Élément | Constat |
|---|---|
| CMS | WordPress + Yoast SEO (thème Bootstrap 3, jQuery) |
| Sitemap | `page-sitemap.xml` → 13 pages |
| robots.txt | `Disallow: /wp-admin/` uniquement |
| Formulaires | POST vers des scripts PHP externes (`/devis-action.php`, `/contact-action.php`) |
| Pied de page | « Site créé par Tanak International Ltd \| Point pneus guerido © 2018 » |

## 2. Arborescence

```
/                                Accueil — « Garage pneus et mécanique - Perpignan »
/pneus-neuf-reparation/          Vente pneus
/pneus-doccasion/                Réparation pneus (+ catégories d'occasion)
/mecanique-garage-automobile/    Mécanique : Garage Automobile   ┐
/nos-pieces-detachees/           Nos pièces détachées            ├ menu « Entretiens »
/renovation-phares/              Rénovation phares               ┘
/27-2/                           Climatisation
/geometrie-3d/                   Géométrie 3D
/devis-mecanique/                Devis mécanique                 ┐ menu « Devis GRATUITS »
/devis-pneus-perpignan/          Devis pneus                     ┘
/galerie-photos/                 En photos
/contact/                        Contact & mentions légales
/decalaminage-moteur/            Décalaminage moteur — orphelin (absent du menu)
```

Le slug `/27-2/` est un slug WordPress accidentel : remplacé par `/climatisation/`.
`/decalaminage-moteur/` n'est plus lié depuis le menu mais reste publié : conservé et remis dans la navigation.

## 3. Informations d'entreprise (à conserver telles quelles)

- **Raison sociale** : Point Pneus Guerido, SARL au capital de 7 622,45 €
- **Adresse** : 9 Rue Henri Becquerel, 66330 Cabestany
- **Téléphone** : 04 68 50 50 68
- **E-mail** : pointpneusguerido@free.fr
- **RCS** : Perpignan 450 045 430 — **TVA** : FR92450045430
- **Directrice de la publication** : FRANCO Marilyne, gérante
- **Hébergeur** : OVH SAS, 2 rue Kellermann, 59100 Roubaix
- **Horaires** : lundi au vendredi 8h–12h / 14h–18h30 — samedi fermé
- **Baseline (logo)** : « Le spécialiste en pneu neuf et occasion »

Mentions légales également présentes : liste d'opposition **Bloctel**, **médiateur Mobilians** (CNPA).

## 4. Contenus par page

### Accueil
- H1 « Garage pneus et mécanique - Perpignan »
- Deux blocs : « Pneus : vente et montage », « Mécanique générale »
- « Nos services » : Centre de montage · Parallélisme / équilibrage · Mécanique générale ·
  Rénovation phares · Pose plaque d'immatriculation · Recharge climatisation
- « Nos engagements » : Service rapide et de qualité · Point Pneus aligne ses prix ·
  Recyclage des pneus usagés · Service Professionnel
- « Qui sommes-nous ?.. » : marques citées — Michelin, Bridgestone, Firestone, Hankook,
  Hanksugi, Wanli, Goodyear, Continental, Nova
- « Pourquoi nous choisir ? » : large assortiment + conseils · pièces de rechange de qualité ·
  garantie totale pièces et main d'œuvre
- « Le garage » : galerie de vignettes
- Deux formulaires de pré-qualification (pneus / mécanique) renvoyant vers les pages devis
- **Déchet à supprimer** : la chaîne `fsgdfgf` présente dans le HTML de production

### Vente pneus (`/pneus-neuf-reparation/`)
Prix exceptionnels pneus neufs et occasions* (tourisme, 4x4, camionnette).
Prix incluant équilibrage, valves et montage.
Tarifs réparation : **vulcanisation à chaud (tourisme) 30 €**, **réparation mèche 15 €**.

### Réparation pneus (`/pneus-doccasion/`)
Conformité des réparations, marquage « REP » depuis le 01/01/2008.
Catégories d'occasion : Cat. 1 faible usure état neuf grande marque · Cat. 2 faible usure état
neuf autre marque · **Cat. 3 usure 50 % à partir de 11,00 €**.

### Mécanique (`/mecanique-garage-automobile/`)
Services garage traditionnel : Entretien · Vidange · Embrayage · Distribution · Échappement · Cardans.
Sécurité : Freins · Suspension · Pneumatiques · Rénovation phares.

### Nos pièces détachées
4 familles : **Pièces Moteur** · **Direction-Suspension-Train** · **Freinage** · **Électricité**,
avec 5–6 sous-items chacune.

### Rénovation phares
Polycarbonate, jaunissement UV, perte de vision nocturne 30–40 %, refus au contrôle technique
depuis le 01/01/2010. Argument : **70 % moins cher que le remplacement d'un optique neuf**.

### Climatisation (`/27-2/`)
**Forfait Clim 65 € (R134)** et **Forfait Clim 130 € (R1234Y)**.
Contenu du forfait, périodicité (recharge tous les 2 ans, filtre habitacle tous les ans),
symptômes. Mentions : offre réservée aux particuliers, non cumulable, photos non contractuelles.

### Géométrie 3D
Conséquences d'une géométrie déréglée, avantages du réglage.
Tarifs : **parallélisme avant 65 €**, **avant + arrière & carrossage 85 €**,
**avant + arrière & carrossage 4×4 / camionnette 100 €**.

### Décalaminage moteur
DKBOOST © — plus de 70 % des véhicules concernés par la calamine ; efficace sur vannes EGR et FAP.

### Galerie photos
≈ 55 photos de l'atelier et des prestations.

### Contact
Page de mentions légales + invitation à téléphoner. Formulaire « Demande d'informations » réduit
à un champ caché côté HTML (aucun champ visible exploitable).

## 5. Formulaires relevés (structure uniquement — **jamais soumis**)

### Devis pneus → `POST /devis-action.php` (`objet = "Devis pour pneumatique"`)
`type_pneus` (Été / Hiver / Toute saison) · `marques` radio (Eco budget / Marque premium / Occasion) ·
`qte` · `dimension[]` × 5 (largeur 135→375, hauteur 80→25, diamètre 13→24, indice de charge 68→120,
indice de vitesse S/T/H/V/W/Y/Z) · `specificite` radio (Run Flat / Pax System) ·
`marque_vehicule`* · `type_vehicule`* · `immatriculation_vehicule`* · `date_circulation` ·
`motorisation` · `email`* · `nom`* · `prenom` · `adresse` · `cp` · `ville` · `tel`* · `remarques`

### Devis mécanique → `POST /devis-action.php` (`objet = "Devis pour mecanique et entretiens"`)
`entretien[]` cases à cocher (Freinage, Kit de distribution, Embrayage, Échappement, Révision,
Vidange, Pompe à eau, Autre réparation) · `marques` · mêmes champs véhicule et coordonnées.

### Contact → `POST /contact-action.php?form=1` (`objet = "Demande d'informations"`)
Aucun champ visible. Reproduit dans la refonte sous forme d'un formulaire de contact standard
(nom, e-mail, téléphone, message) — fonctionnalité, pas information commerciale.

(*) champ obligatoire côté site existant.

## 6. Médias

104 fichiers téléchargés (originaux, ≈ 15 Mo) : logo, photos atelier, illustrations
climatisation / géométrie / décalaminage / rénovation phares, galerie.
Les 11 logos de marques sont fournis en 35 px de haut → inexploitables, remplacés par une
liste typographique des marques citées.

## 7. SEO existant

Titles se terminant par « - » (site name vide), pas de `meta description` sur plusieurs pages,
aucun `alt` sur presque toutes les images, hiérarchie de titres incohérente
(H5 avant H2, H1 absent sur la majorité des pages), deux blocs de bourrage de mots-clés en
pied de page (« Mots - clés relatifs », « Villes d'intervention »).

## 8. Décisions de reprise

| Élément | Décision |
|---|---|
| Coordonnées, horaires, tarifs, forfaits, catégories | **Conservés à l'identique** |
| Textes de service (clim, géométrie, phares, décalaminage) | Conservés, remis en forme |
| Formulaires devis pneus / devis mécanique | Reproduits champ pour champ |
| Formulaire contact | Reproduit avec des champs utilisables |
| Bourrage de mots-clés + liste de villes | **Supprimés** (nocifs pour le SEO) |
| Logos de marques 35 px | Remplacés par les noms de marques en texte |
| Slug `/27-2/` | Renommé `/climatisation/` |
| `fsgdfgf` | Supprimé |
| Crédit « Tanak International Ltd » | **Retiré.** Le site a été refait : laisser ce crédit attribuerait la refonte à un auteur qui ne l'a pas faite |
| Astérisques sans renvoi sur les tarifs de géométrie | Astérisques retirés, prix inchangés (aucune note n'existait sur le site source) |
| « température de l'habitable » (forfait clim) | Coquille corrigée en « habitacle », sens inchangé |
| Menus « Entretiens » et « Devis GRATUITS » (liens morts) | Transformés en vraies pages de rubrique listant leurs sous-pages |

Aucun prix, horaire, marque, prestation, certification ni avis client n'a été inventé.

> **Passe de correction (15/09/2026)** — une relecture éditoriale a retiré les formulations
> ajoutées à la reprise qui n'avaient pas de source dans cet audit (délai de réponse, arguments
> « pourquoi nous choisir », descriptions du garage, usure « 0 à 15 % », test « par une entreprise
> agréée »). Le détail est dans [`docs/CORRECTIONS.md`](CORRECTIONS.md).
