# Mission

Tu vas réaliser une **refonte complète du site https://www.point-pneus-guerido.com/** sous forme d'une nouvelle application **Ruby on Rails 8**, avec **Ruby 4.0.5** et **MySQL**.

Le projet doit être pensé comme un **mini-CMS administrable**, et non comme une simple intégration HTML/CSS du site actuel.

L'objectif est de conserver les **informations, contenus, services, formulaires et fonctionnalités utiles du site existant**, tout en proposant un **front-end entièrement repensé, moderne, premium, responsive et cohérent avec l'activité automobile/pneumatique**.

---

# 1. Analyse préalable obligatoire

Avant de commencer à développer, commence par **auditer le site existant**.

Tu peux parcourir/fetcher les pages publiques du site afin d'identifier :

- l'arborescence ;
- les pages ;
- les sections de chaque page ;
- les textes ;
- les titres et sous-titres ;
- les CTA ;
- les coordonnées ;
- les horaires ;
- les services ;
- les informations commerciales ;
- les images ;
- les logos ;
- les icônes ;
- les formulaires ;
- les champs des formulaires ;
- les messages et comportements visibles côté front ;
- les liens internes ;
- les liens externes ;
- les informations de contact ;
- les éventuels éléments SEO ;
- les éléments récurrents du header/footer ;
- les éléments qui semblent être des composants réutilisables.

### Important

**NE SOUMETS AUCUN FORMULAIRE pendant l'analyse du site existant.**

Tu peux :

- afficher les pages ;
- inspecter les formulaires ;
- identifier leurs champs ;
- identifier leurs labels ;
- reproduire leur structure ;
- comprendre leur fonctionnement apparent.

Mais **aucun formulaire réel du site existant ne doit être soumis**.

Ne déclenche aucune demande de devis, prise de rendez-vous, demande de contact ou autre action qui pourrait générer une demande réelle auprès de l'entreprise.

---

# 2. Transformation du contenu en données

Ne hardcode pas les contenus du site dans les vues Rails.

Le contenu récupéré lors de l'audit doit être transformé en **données gérées par le CMS**.

L'idée est de pouvoir modifier depuis le backoffice :

- les textes ;
- les titres ;
- les images ;
- les CTA ;
- les liens ;
- les sections ;
- l'ordre des sections ;
- l'activation/désactivation des sections.

Le site public doit donc être rendu dynamiquement à partir des données du CMS.

---

# 3. Architecture du mini-CMS

Construis une vraie partie `/admin`.

Elle doit permettre au client de gérer le contenu du site sans modifier le code.

Prévois notamment :

## Pages

CRUD permettant de gérer :

- titre ;
- slug ;
- statut publié/brouillon ;
- SEO title ;
- meta description ;
- éventuellement une image Open Graph ;
- contenu composé de sections.

## Sections

Les pages doivent être composées de sections ordonnables.

Une section doit pouvoir être :

- créée ;
- modifiée ;
- supprimée ;
- activée/désactivée ;
- déplacée vers le haut ;
- déplacée vers le bas.

Prévois une architecture suffisamment flexible pour pouvoir ajouter de nouveaux types de sections plus tard.

Exemples de types possibles :

- Hero ;
- texte + image ;
- grille de services ;
- cartes ;
- arguments/chiffres clés ;
- CTA ;
- galerie ;
- témoignages ;
- horaires ;
- coordonnées ;
- carte/localisation ;
- formulaire ;
- bandeau ;
- contenu libre.

**Ne crée pas une architecture où chaque page possède des colonnes spécifiques impossibles à réutiliser.**

Le système doit être pensé comme un petit page builder maîtrisé.

---

# 4. Gestion des images

Utilise **Active Storage**.

Le backoffice doit permettre :

- upload d'image ;
- remplacement d'image ;
- suppression ;
- aperçu ;
- utilisation d'une image dans une section.

Les images doivent être associées aux contenus plutôt que simplement référencées par des URLs hardcodées.

Prévois également des variantes/resizes adaptés au front afin d'éviter de charger systématiquement des images originales trop lourdes.

---

# 5. Ordre des sections

L'ordre des sections doit être stocké en base.

Utilise par exemple un champ `position` ou une solution équivalente.

Le backoffice doit proposer une UX simple pour réordonner les sections.

Une solution drag & drop est préférable si elle reste raisonnable techniquement.

Le front doit toujours afficher les sections selon leur ordre configuré dans le backoffice.

---

# 6. Formulaires

Reproduis les formulaires actuellement présents sur le site.

**Attention : il s'agit de reproduire leur fonctionnement dans le nouveau site, pas de connecter les formulaires du nouveau site au système de l'ancien site.**

Lorsqu'un visiteur soumet un formulaire sur le nouveau site :

1. les données sont validées ;
2. elles sont enregistrées en base ;
3. une entrée est créée dans le backoffice ;
4. l'administrateur peut consulter la demande.

Dans le backoffice, prévois une rubrique permettant de consulter les soumissions.

Une soumission doit au minimum contenir :

- type de formulaire ;
- date ;
- données envoyées ;
- statut.

Exemples de statuts :

- nouveau ;
- en cours ;
- traité ;
- archivé.

L'administrateur doit pouvoir consulter le détail d'une demande et modifier son statut.

Prévois une validation serveur sérieuse et des messages d'erreur/succès propres.

**Ne jamais stocker de données sensibles inutilement.**

---

# 7. Backoffice

Le backoffice doit être propre et réellement utilisable.

Prévois au minimum :

### Dashboard

Afficher par exemple :

- nombre de pages ;
- pages publiées ;
- nombre de demandes reçues ;
- dernières demandes ;
- éventuellement statistiques simples.

### Gestion des pages

- liste ;
- création ;
- édition ;
- publication/dépublication ;
- suppression ;
- aperçu.

### Gestion des sections

- liste ;
- édition ;
- activation/désactivation ;
- réordonnancement.

### Gestion des médias

- liste des images ;
- upload ;
- suppression ;
- aperçu.

### Gestion des formulaires

- liste des soumissions ;
- filtres ;
- détail ;
- changement de statut.

---

# 8. Authentification administrateur

Le backoffice doit être protégé par authentification.

Ne laisse aucune route `/admin` accessible publiquement.

Utilise une solution Rails moderne et raisonnable pour l'authentification.

Prévois au minimum :

- login ;
- logout ;
- session sécurisée ;
- protection des routes admin.

---

# 9. Refonte graphique

Le front actuel doit être considéré comme une **source de contenu et de compréhension fonctionnelle**, pas comme une référence graphique.

Je veux une **vraie refonte UI/UX**.

Le résultat doit être :

- moderne ;
- premium ;
- professionnel ;
- automobile ;
- lisible ;
- rassurant ;
- local et humain ;
- responsive ;
- performant ;
- accessible.

Évite absolument :

- les interfaces génériques générées par IA ;
- les gradients gratuits ;
- les glassmorphisms systématiques ;
- les énormes titres sans hiérarchie ;
- les cartes identiques répétées partout ;
- les layouts SaaS génériques ;
- les animations inutiles ;
- l'esthétique "landing page AI".

Le design doit donner l'impression d'avoir été réalisé par un **designer web expérimenté pour un professionnel de l'automobile**, pas par un générateur de templates.

---

# 10. Utilisation du skill frontend design

Le projet dispose déjà du skill :

`npx claude-code-templates@latest --skill creative-design/frontend-design`

**Utilise réellement ce skill dans la conception du front.**

Ne te contente pas de mentionner son existence.

Appuie-toi dessus pour :

- définir une direction artistique ;
- construire une hiérarchie visuelle ;
- travailler la typographie ;
- concevoir les layouts ;
- gérer les espacements ;
- définir les composants ;
- concevoir les interactions ;
- créer un responsive cohérent ;
- éviter les patterns d'AI slop.

Avant de coder massivement le front, définis une **direction artistique cohérente**.

---

# 11. Design system

Crée un petit design system cohérent :

- typographies ;
- tailles de texte ;
- couleurs ;
- espacements ;
- border radius ;
- ombres ;
- boutons ;
- champs ;
- cartes ;
- badges ;
- composants de navigation ;
- états hover/focus/disabled ;
- responsive breakpoints.

Les composants doivent être réutilisables.

Évite de créer une variation différente d'un même composant à chaque endroit.

---

# 12. Responsive

Le site doit être conçu **mobile-first**.

Teste au minimum :

- mobile ;
- tablette ;
- desktop ;
- grands écrans.

Le menu mobile doit être réellement pensé pour le tactile.

Les formulaires doivent être particulièrement soignés sur mobile.

---

# 13. SEO

Prévois une base SEO correcte :

- URLs propres ;
- slugs ;
- title dynamique ;
- meta description ;
- canonical si nécessaire ;
- Open Graph ;
- sitemap ;
- robots.txt ;
- balises sémantiques ;
- structure H1/H2/H3 cohérente ;
- alt text pour les images.

Les contenus SEO doivent être administrables depuis le backoffice lorsque cela a du sens.

---

# 14. Performance

Le site doit être rapide.

Porte une attention particulière à :

- poids des images ;
- lazy loading ;
- dimensions des images ;
- nombre de requêtes ;
- JavaScript inutile ;
- CSS ;
- cache ;
- requêtes SQL ;
- N+1 queries.

Utilise les mécanismes natifs de Rails autant que possible.

---

# 15. Sécurité

Applique les bonnes pratiques Rails :

- CSRF ;
- strong parameters ;
- validations ;
- autorisation des actions admin ;
- protection des uploads ;
- validation des types de fichiers ;
- protection contre les injections ;
- sessions sécurisées ;
- aucune donnée de formulaire affichée sans échappement.

Ne fais jamais confiance aux données provenant du navigateur.

---

# 16. Architecture technique

Stack cible :

- Ruby 4.0.5 ;
- Rails 8 ;
- MySQL ;
- Active Storage ;
- Hotwire/Turbo/Stimulus lorsque pertinent.

Privilégie une architecture Rails idiomatique.

Évite d'ajouter des dépendances npm ou gems inutilement.

Avant d'ajouter une librairie, vérifie si Rails 8 ou le navigateur permettent de faire la même chose simplement.

---

# 17. Modèle de données

Propose et implémente un modèle de données cohérent.

À titre indicatif, tu peux partir sur quelque chose comme :

- `AdminUser`
- `Page`
- `Section`
- `Media`
- `FormSubmission`
- éventuellement `SiteSetting`

Mais adapte le modèle si ton audit révèle une meilleure architecture.

Le schéma doit permettre de faire évoluer le CMS.

---

# 18. Données initiales

Une fois l'audit terminé :

- récupère les contenus publics pertinents ;
- récupère les informations nécessaires ;
- récupère les images publiques utilisables ;
- crée les données initiales du CMS ;
- crée les pages ;
- crée les sections ;
- définit leurs positions ;
- associe les médias.

Le résultat doit permettre d'obtenir immédiatement un site fonctionnel avec le contenu initial.

**Ne fais pas simplement des copier/coller de HTML dans Rails.**

Le contenu doit être correctement structuré dans les modèles du CMS.

---

# 19. Respect du site existant

Le nouveau site doit reprendre les informations pertinentes du site existant, mais **pas nécessairement sa structure ou son apparence**.

Tu dois être capable de distinguer :

- contenu à conserver ;
- fonctionnalité à reproduire ;
- élément obsolète ;
- élément purement esthétique ;
- élément pouvant être amélioré.

Si une information semble ambiguë, conserve-la plutôt que d'inventer une information commerciale.

**N'invente jamais :**

- prix ;
- prestations ;
- horaires ;
- marques ;
- certifications ;
- coordonnées ;
- avis clients ;
- engagements commerciaux.

---

# 20. Formulaires : règle absolue pendant l'audit

Cette règle est prioritaire :

> **NE SOUMETS JAMAIS UN FORMULAIRE DU SITE EXISTANT.**

L'audit doit rester en lecture seule.

Tu peux inspecter le HTML, les champs et le comportement apparent, mais aucune demande ne doit être envoyée à l'entreprise.

---

# 21. Tests

Mets en place des tests pertinents.

Au minimum, couvre :

### Modèles

- validations ;
- relations ;
- positions ;
- statuts.

### Formulaires

- validation ;
- création d'une soumission ;
- données invalides ;
- données manquantes.

### Admin

- accès authentifié ;
- accès refusé sans authentification ;
- CRUD pages ;
- CRUD sections ;
- réordonnancement ;
- gestion des soumissions.

### Front

Vérifie notamment :

- affichage des pages ;
- ordre des sections ;
- sections désactivées ;
- formulaires ;
- responsive.

---

# 22. Méthode de travail obligatoire

Travaille dans cet ordre :

### Phase 1 — Audit

Analyse le site existant et documente :

- pages ;
- sections ;
- contenus ;
- images ;
- formulaires ;
- fonctionnalités.

**Aucune soumission de formulaire.**

### Phase 2 — Architecture

Définis :

- architecture Rails ;
- modèles ;
- relations ;
- routes ;
- architecture CMS ;
- stratégie des sections ;
- stratégie média.

### Phase 3 — Design

Définis la direction artistique et le design system.

### Phase 4 — Backend

Implémente :

- modèles ;
- migrations ;
- validations ;
- Active Storage ;
- authentification admin ;
- CMS ;
- soumissions de formulaires.

### Phase 5 — Backoffice

Construis l'interface d'administration.

### Phase 6 — Front

Construis le nouveau front à partir des données du CMS.

### Phase 7 — Seed

Importe le contenu initial récupéré lors de l'audit.

### Phase 8 — Tests

Teste les principales fonctionnalités.

### Phase 9 — QA

Vérifie :

- responsive ;
- navigation ;
- formulaires ;
- erreurs ;
- accessibilité ;
- performance ;
- SEO ;
- sécurité.

---

# 23. Critères de réussite

Le projet est considéré comme terminé lorsque :

- le site public est entièrement fonctionnel ;
- le contenu initial du site existant a été intégré ;
- le contenu n'est pas hardcodé dans les vues ;
- les pages sont administrables ;
- les sections sont administrables ;
- l'ordre des sections est modifiable ;
- les images sont administrables ;
- les formulaires fonctionnent ;
- chaque soumission est enregistrée en base ;
- les soumissions sont consultables dans le backoffice ;
- le backoffice est protégé ;
- le site est responsive ;
- le design est clairement différent et plus qualitatif que le site actuel ;
- aucune information commerciale n'a été inventée ;
- aucun formulaire du site existant n'a été soumis pendant l'audit ;
- les principaux comportements sont couverts par des tests.

---

# 24. Consigne importante sur la qualité

Ne cherche pas à terminer rapidement en générant une grosse quantité de code.

Privilégie :

1. compréhension ;
2. architecture ;
3. cohérence ;
4. qualité UX ;
5. maintenabilité ;
6. tests ;
7. performance.

Si tu rencontres une ambiguïté technique, choisis la solution **la plus simple, idiomatique Rails et évolutive**, plutôt que d'introduire une architecture inutilement complexe.

Le résultat final doit ressembler à une **application Rails professionnelle avec un mini-CMS réellement exploitable**, et non à une démo ou à un prototype généré automatiquement.