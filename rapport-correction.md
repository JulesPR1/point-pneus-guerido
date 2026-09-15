# Rapport de correction de l’AI slop d’un site web

## Objectif

Transformer le site en une expérience crédible, spécifique, utile et éditorialement assumée. Réduire les signaux visuels, structurels et rédactionnels associés à l’« AI slop » sans inventer de faits, clients, chiffres, témoignages, certifications ou fonctionnalités.

**Instruction centrale :** ne pas essayer de masquer le problème par un simple changement de palette, de typographie ou d’illustrations. Corriger les causes structurelles et éditoriales : contenu interchangeable, promesses non prouvées, hiérarchie prévisible, composants décoratifs sans fonction et absence de point de vue.

Le présent document est volontairement indépendant de tout framework, CMS ou design system.

## Définition de l’AI slop

Dans ce cahier des charges, l’AI slop désigne un ensemble de signaux qui font paraître un site produit rapidement, sans travail éditorial, sans expertise identifiable ni attention au contexte. L’usage d’outils d’IA n’est pas, à lui seul, un problème. Le problème est un résultat : générique, interchangeable, surabondant, non vérifiable ou artificiellement « premium ».

Un site ne doit pas :

- formuler des promesses que n’importe quel concurrent pourrait reprendre telles quelles ;
- employer des superlatifs ou termes vagues à la place de preuves ;
- utiliser des motifs d’interface répétés sans nécessité ;
- simuler l’authenticité par de faux avis, métriques, logos, images ou études de cas ;
- publier du contenu en volume sans valeur pratique, expertise, sources ou intention claire.

## Principes directeurs

1. **Préférer le spécifique au séduisant.** Nommer clairement l’offre, le public, le contexte, les limites et le résultat attendu.
2. **Préférer la preuve à l’affirmation.** Toute promesse importante doit être justifiée, nuancée ou retirée.
3. **Préférer l’utilité à la densité.** Chaque section, mot, carte, image et CTA doit avoir une fonction identifiable.
4. **Préférer une structure adaptée au contenu à un modèle de landing page.** Ne pas forcer Hero → cartes → témoignages → FAQ → CTA si cela n’améliore pas la compréhension.
5. **Préférer l’authenticité au remplissage.** En l’absence de matériau réel, utiliser une formulation sobre ou un emplacement explicitement à compléter ; ne jamais inventer.
6. **Préférer l’accessibilité et la lisibilité aux effets décoratifs.** Les effets ne doivent ni porter l’information ni dégrader la lecture.
7. **Conserver la cohérence.** Un vocabulaire, une voix, une hiérarchie et des composants identiques doivent signifier la même chose partout.

## Audit en 10 dimensions

Auditer chaque page, puis consolider les observations au niveau du site.

| Dimension | Questions d’audit | Signal à corriger |
|---|---|---|
| 1. Proposition de valeur | Comprend-on quoi est proposé, pour qui et pourquoi cela compte en quelques secondes ? | Accroche vague, promesse universelle, jargon.
| 2. Spécificité éditoriale | Le texte pourrait-il être copié chez un concurrent sans changement ? | Contenu interchangeable et tonalité corporate.
| 3. Preuves | Les bénéfices, chiffres, avis et comparatifs sont-ils sourcés et honnêtes ? | Affirmations sans support, preuves décoratives ou inventées.
| 4. Architecture de l’information | L’ordre des sections répond-il aux questions réelles du visiteur ? | Template de landing page répété, sections redondantes.
| 5. Utilité du contenu | Chaque page répond-elle à une intention concrète avec une information exploitable ? | Paragraphes fluides mais vides, SEO de remplissage.
| 6. Voix et ton | Le ton est-il humain, précis et proportionné au sujet ? | Enthousiasme uniforme, superlatifs, métaphores génériques.
| 7. UI et hiérarchie visuelle | Les éléments visuels guident-ils une décision ou une compréhension ? | Cartes en série, badges, dégradés, halos et pictogrammes gratuits.
| 8. Images et médias | Les médias informent-ils réellement ou ne font-ils que décorer ? | Visuels de stock stéréotypés, illustrations IA génériques, portraits fictifs.
| 9. Interactions et confiance | Les CTA, formulaires et microcopies sont-ils clairs, sobres et crédibles ? | Urgence artificielle, faux compteurs, CTA interchangeables.
| 10. Implémentation | Les composants rendent-ils le contenu cohérent sans l’aplatir ? | Composants fourre-tout, données factices codées en dur, duplication.

## Tableau de corrections

La priorité est définie ainsi : **P0** = risque de tromperie ou de confiance, à traiter avant publication ; **P1** = bloque fortement la compréhension ou la crédibilité ; **P2** = amélioration importante de qualité et cohérence ; **P3** = finition, à traiter après le reste.

| Problème | Priorité | Correction attendue | Critères d’acceptation |
|---|---:|---|---|
| Preuves, avis, logos, chiffres ou études de cas non vérifiables | P0 | Retirer, remplacer par une source vérifiable ou marquer comme contenu à fournir. | Aucun fait important ne reste sans origine identifiable ; aucune donnée fictive n’est publiée.
| Promesse trompeuse ou absolue (« garanti », « le meilleur », « révolutionnaire ») | P0 | Nuancer avec les conditions réelles, documenter la preuve ou supprimer. | Toute promesse peut être défendue par un élément réel et accessible.
| Faux signaux d’urgence ou de popularité | P0 | Retirer les compteurs, stock limité, notifications sociales ou échéances non réelles. | Les mécanismes de conversion reflètent une contrainte authentique.
| Hero générique | P1 | Réécrire avec : offre précise, public visé, résultat ou usage, et CTA explicite. | Le hero répond à « quoi / pour qui / dans quel contexte » sans jargon.
| Jargon et buzzwords | P1 | Remplacer par un vocabulaire métier compréhensible ; supprimer les adjectifs qui n’ajoutent pas de sens. | Chaque adjectif modifie concrètement le sens ou est supprimé.
| Bénéfices sans mécanisme | P1 | Expliquer comment le produit ou service produit le résultat ; ajouter une preuve si disponible. | Chaque bénéfice majeur est relié à une capacité, un processus ou une limite.
| Structure de page calquée sur une landing page standard | P1 | Réordonner ou supprimer les sections selon les questions prioritaires du visiteur. | Aucun bloc ne subsiste uniquement parce qu’il est habituel dans un template.
| Cartes répétitives sans différence fonctionnelle | P1 | Fusionner, transformer en liste comparative, tableau, étapes ou texte direct selon le contenu. | Chaque carte présente une information distincte qui nécessite réellement ce format.
| Texte long mais peu informatif | P1 | Réduire, ajouter détails exploitables, exemples réels, contraintes, étapes ou sources. | Chaque paragraphe apporte au moins une information, décision ou action nouvelle.
| Ton publicitaire uniforme | P2 | Introduire précision, limites, conditions et vocabulaire naturel ; garder une voix cohérente. | La page ne dépend pas de superlatifs pour convaincre.
| CTA vagues (« En savoir plus », « Découvrir ») | P2 | Nommer l’action et sa conséquence : « Voir les tarifs », « Demander une démo », etc. | Chaque CTA est compréhensible hors contexte et correspond à sa destination.
| FAQ utilisée pour répéter le marketing | P2 | Conserver uniquement les questions réelles ; répondre directement et ajouter des liens utiles. | Chaque réponse lève une objection ou apporte une information non répétée.
| Iconographie ou illustrations génériques | P2 | Remplacer par une preuve, capture, schéma informatif, image propre au sujet, ou supprimer. | Chaque média apporte un contexte ou une information non présente dans le texte.
| Design « premium » décoratif | P2 | Réduire halos, dégradés, verre dépoli, badges et animations sans fonction ; renforcer contraste et hiérarchie. | Les effets visuels ne compromettent ni lisibilité ni crédibilité, et servent une intention claire.
| Pages SEO prolifiques et interchangeables | P1 | Consolider, réécrire autour d’une intention précise, ou dépublier si aucune valeur unique n’est possible. | Chaque page a un objectif de recherche distinct, une réponse complète et une valeur propre.
| Images de personnes ou d’équipes ambiguës | P0 | Identifier clairement leur statut, utiliser des médias authentiques autorisés, ou retirer. | Aucune image ne laisse croire à une personne, un client ou une équipe inexistante.
| Composants qui imposent le même récit partout | P2 | Prévoir des variantes sémantiques et composer les pages à partir du besoin éditorial. | La réutilisation ne force pas des titres, CTA ou blocs artificiels.
| Microcopies excessivement enthousiastes | P3 | Simplifier confirmations, états vides, erreurs et libellés. | Les microcopies sont courtes, explicites, utiles et proportionnées.
| Animations décoratives ou continuelles | P3 | Supprimer ou limiter ; respecter les préférences de réduction des mouvements. | L’information reste accessible sans animation ; aucune animation ne gêne la tâche.

## Règles de design et d’interface

- Construire la hiérarchie à partir de l’importance de l’information, non d’un style visuel à la mode.
- Limiter les motifs répétitifs : rangées de trois cartes, badges partout, icônes circulaires et fonds dégradés ne sont pas une structure de contenu.
- Ne conserver une carte que si elle isole une unité réellement comparable, actionnable ou navigable.
- Faire primer titres, descriptions, données, médias et actions sur les ornements.
- Employer une typographie lisible, une échelle de titres stable, des contrastes suffisants et des états interactifs visibles.
- Éviter les images décoratives génériques. Privilégier les captures annotées, schémas, photos réelles autorisées, échantillons ou démonstrations, uniquement lorsqu’ils informent.
- Ne pas utiliser de visages, logos, témoignages ou métriques pour créer une impression de preuve sans autorisation et traçabilité.
- Rendre les formulaires explicites : données demandées, raison de la demande, attente après soumission et erreurs actionnables.
- Concevoir l’interface pour le clavier, les lecteurs d’écran, les petits écrans et les préférences de mouvement réduit.

## Règles de contenu et de SEO

- Réécrire pour une intention de visite ou de recherche définie, une page à la fois.
- Commencer par l’information décisive, puis détailler fonctionnement, critères, limites, alternatives et prochaine action.
- Utiliser des mots simples. Remplacer les formulations vagues par des noms, verbes, conditions, délais et périmètres réels.
- Supprimer les introductions qui ne font que déclarer l’importance d’un sujet.
- Ne pas produire plusieurs pages visant la même intention avec des variations superficielles de termes ou de lieux.
- Conserver des titres et métadonnées descriptifs, uniques et alignés avec le contenu de la page ; ne pas les surcharger de mots-clés.
- Ajouter des liens internes seulement lorsqu’ils aident réellement la suite du parcours ou la compréhension.
- Citer ou lier les sources lorsque des faits externes, comparaisons, réglementations ou chiffres sont employés.
- Ne pas inventer d’auteur, d’expertise, de date de mise à jour ou de retour d’expérience.

## Règles de preuve et d’originalité

- Établir une liste de toutes les affirmations factuelles, quantitatives ou comparatives avant leur publication.
- Associer à chaque affirmation soit une source, soit un propriétaire interne capable de la valider, soit une reformulation prudente, soit une suppression.
- Distinguer clairement faits, opinions, hypothèses, démonstrations et exemples fictifs.
- Utiliser de vrais cas, décisions, processus, contraintes et détails de métier lorsqu’ils sont disponibles et autorisés.
- Si une information spécifique manque, insérer un marqueur éditorial explicite destiné au propriétaire du contenu ; ne pas le remplacer par du texte plausible.
- Contrôler le risque de répétition : chaque page et section doit apporter un angle, une donnée, une décision ou un exemple qui lui est propre.

## Règles de code et de composants

Ces règles s’appliquent seulement lorsqu’une modification de code est nécessaire.

- Séparer le contenu des composants de présentation afin que les textes, sources, liens et statuts puissent être vérifiés et mis à jour sans modifier la logique visuelle.
- Utiliser des données structurées pour les faits vérifiables (source, date, statut de validation) lorsque le produit le justifie.
- Ne pas coder en dur de faux avis, compteurs, noms, logos, notes, nombres d’utilisateurs ou résultats.
- Créer des composants à responsabilité claire et à variantes limitées, sémantiques et documentées ; ne pas construire un composant « marketing » universel qui force la même page partout.
- Préserver les balises sémantiques, les libellés accessibles, la navigation clavier, le contraste et les préférences `prefers-reduced-motion`.
- Éviter les dépendances et effets lourds dont le seul rôle est décoratif.
- Ajouter ou mettre à jour les tests pertinents pour les parcours, liens, formulaires, états d’erreur et comportements d’accessibilité affectés.

## Procédure d’exécution

1. Inventorier les pages, sections, composants, médias, CTA et affirmations publiques.
2. Évaluer chaque élément selon les 10 dimensions ; noter le problème, la preuve observée, la priorité et le propriétaire nécessaire.
3. Traiter immédiatement les P0 : supprimer ou corriger les éléments trompeurs, fictifs ou non vérifiables.
4. Définir, pour chaque page, l’intention principale, le public, la question à résoudre et l’action suivante attendue.
5. Recomposer l’architecture de la page avant de retoucher son habillage visuel ; supprimer les sections inutiles et fusionner les répétitions.
6. Réécrire titres, paragraphes, CTA, FAQ et microcopies en remplaçant le générique par le précis et le prouvable.
7. Réviser médias, graphiques, logos, citations et chiffres ; retirer ce qui n’est pas autorisé, contextualisé ou utile.
8. Adapter les composants et styles uniquement pour soutenir la nouvelle hiérarchie et l’accessibilité.
9. Vérifier chaque page sur mobile, au clavier et avec les principaux états d’interface ; corriger les régressions.
10. Effectuer une relecture finale en demandant : « Cette page pourrait-elle appartenir à n’importe qui ? Quelle preuve ou information concrète reste-t-il après avoir retiré les adjectifs ? »

## Checklist finale

- [ ] Aucun témoignage, chiffre, logo, profil, image ou urgence artificielle n’est publié.
- [ ] Chaque page annonce clairement son sujet, son public et son utilité.
- [ ] Les promesses majeures sont prouvées, limitées ou retirées.
- [ ] Chaque section a une fonction identifiable ; les sections décoratives ou répétées ont été supprimées.
- [ ] Les CTA décrivent précisément l’action et mènent à la bonne destination.
- [ ] Le langage est concret, cohérent et dénué de jargon inutile.
- [ ] Les médias ajoutent une information réelle ou ont été retirés.
- [ ] Les pages SEO ont une intention distincte et un contenu substantiel.
- [ ] L’interface reste lisible, accessible et cohérente sans les effets décoratifs.
- [ ] Le code ne contient pas de données de confiance factices et les composants ne forcent pas un template générique.
- [ ] Les changements ont été vérifiés sur les parcours et tailles d’écran concernés.

## Définition de done

Le travail est terminé lorsque :

1. tous les P0 sont supprimés ou remplacés par des éléments vérifiables et autorisés ;
2. toutes les pages prioritaires ont une proposition de valeur spécifique, une hiérarchie adaptée et un contenu utile ;
3. les éléments de design ne servent plus à compenser un manque de contenu ou de preuve ;
4. les affirmations restantes sont justifiées, clairement conditionnées ou éditorialement validées ;
5. aucune modification ne se limite à changer couleurs, polices, rayons, ombres ou dégradés pour camoufler les symptômes ;
6. l’interface et les parcours modifiés sont accessibles, fonctionnels et vérifiés.

Le résultat attendu n’est pas un site qui « a l’air moins généré ». C’est un site qui démontre une intention, une expertise, des informations et une identité réellement propres.
