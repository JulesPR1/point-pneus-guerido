# Déployer la démo sur Render (gratuit)

Mettre en ligne une démo publique du site et du backoffice `/admin`, sans carte bancaire,
en ~20 minutes dont 10 de build.

Le dépôt est **déjà préparé** : image Docker, entrypoint, base SQLite de démo, blueprint Render.
Il n'y a rien à copier-coller depuis ce document — seulement des étapes à suivre.

> **Démo ≠ production.** L'offre gratuite de Render met le service en veille après ~15 min sans
> visite (réveil de 30 s à 1 min) et son disque est éphémère : à chaque redéploiement ou réveil
> à froid, la base et les images sont reconstruites depuis `db/seeds.rb`. Toute saisie faite
> dans `/admin` est perdue. Voir §7 si le garage doit conserver ses modifications.

---

## 1. Ce qui a été ajouté au dépôt

| Fichier | Rôle |
|---|---|
| `Dockerfile` | Image multi-étages `ruby:4.0.5-slim` → gems, `libvips`, précompilation des assets, utilisateur non-root |
| `bin/docker-entrypoint` | Lance `db:prepare`, puis `db:seed` si `SEED_ON_BOOT=1`, avant Puma |
| `.dockerignore` | Exclut `.git`, `docs`, `test`, les logs… et **`config/master.key`** |
| `render.yaml` | Blueprint Render : service web Docker, plan `free`, région Frankfurt, health check `/up` |
| `config/database.yml` | Bloc `production` conditionnel : SQLite si `DEMO_SQLITE=1`, **MySQL inchangé sinon** |
| `Gemfile` / `Gemfile.lock` | `gem "sqlite3"` dans le groupe `production` (binaire précompilé, aucune compilation) |
| `config/cable.yml` | Production passée de `redis` à `async` — aucun canal n'est diffusé par l'app, plus besoin d'un Redis |
| `config/environments/production.rb` | `config.force_ssl` pilotable par `FORCE_SSL` (pour tester l'image en local) |

Rien de tout cela ne modifie le comportement MySQL habituel : sans `DEMO_SQLITE=1`,
l'application se connecte à MySQL exactement comme avant.

Validé localement le 15/09/2026 : build Docker OK, boot + seed en 6 s, 15 pages / 54 sections /
113 éléments / 9 médias, variantes libvips générées (JPEG 174 ko), 188 Mo de RAM en veille
(limite Render free : 512 Mo), `bin/rails test` 144 runs / 0 failure.

---

## 2. Prérequis

- Le dépôt poussé sur **GitHub** (ou GitLab). Dépôt privé accepté.
- Un compte **Render** (inscription avec GitHub, aucune carte demandée pour le plan Free).
- Deux secrets à préparer :

  ```bash
  openssl rand -hex 64     # → SECRET_KEY_BASE
  openssl rand -base64 24  # → ADMIN_PASSWORD (ou votre propre mot de passe long)
  ```

---

## 3. Déploiement

### Option A — Blueprint (le plus rapide)

1. Pousser la branche contenant `render.yaml` (par défaut : `main`).
2. Render → **New → Blueprint** → sélectionner le dépôt → **Apply**.
3. Render lit `render.yaml` et demande les deux variables marquées `sync: false` :
   `ADMIN_EMAIL` et `ADMIN_PASSWORD`. `SECRET_KEY_BASE` est généré automatiquement.
4. Le build démarre. 5 à 10 min la première fois.

### Option B — Service créé à la main

1. Render → **New → Web Service** → connecter le dépôt.
2. Réglages :

   | Champ | Valeur |
   |---|---|
   | Language / Runtime | `Docker` |
   | Branch | `main` |
   | Region | `Frankfurt (EU Central)` |
   | Instance Type | `Free` |
   | Health Check Path | `/up` |
   | Dockerfile Path | `./Dockerfile` (par défaut) |

3. Variables d'environnement :

   | Clé | Valeur | Obligatoire |
   |---|---|---|
   | `SECRET_KEY_BASE` | sortie de `openssl rand -hex 64` | ✅ |
   | `DEMO_SQLITE` | `1` | ✅ |
   | `SEED_ON_BOOT` | `1` | ✅ (premier déploiement) |
   | `ADMIN_EMAIL` | l'identifiant remis au garage | ✅ |
   | `ADMIN_PASSWORD` | mot de passe long | ✅ |
   | `RAILS_MAX_THREADS` | `3` | recommandé |
   | `WEB_CONCURRENCY` | `1` | recommandé (512 Mo de RAM) |
   | `RAILS_LOG_LEVEL` | `info` | facultatif |

   Ne pas définir `PORT` : Render l'injecte, `config/puma.rb` le lit déjà.
   Ne pas définir `RAILS_MASTER_KEY` : `SECRET_KEY_BASE` suffit et évite d'exposer la clé maître.

4. **Create Web Service**.

URL obtenue : `https://<nom-du-service>.onrender.com`.

---

## 4. Recette après mise en ligne

| # | Vérification | Attendu |
|---|---|---|
| 1 | Logs Render, fin du démarrage | `Terminé. 15 pages (15 publiées), 54 sections,` puis `Listening on http://0.0.0.0:...` |
| 2 | `curl -sI https://<url>/up` | `200` |
| 3 | Accueil | Sections dans l'ordre, images affichées (la 1re génération de variante est plus lente) |
| 4 | `/pneus-neuf-reparation`, `/mecanique-garage-automobile`, `/climatisation` | `200` |
| 5 | `/sitemap.xml` | XML listant les pages publiées |
| 6 | Formulaire public | Message de succès, demande visible dans `/admin/demandes` |
| 7 | `/admin` en navigation privée | Redirection vers la page de connexion |
| 8 | Connexion `ADMIN_EMAIL` / `ADMIN_PASSWORD` | Tableau de bord |
| 9 | Modifier une section, revenir au site | Changement visible |
| 10 | Mobile 375 px | Aucun débordement horizontal |

---

## 5. Exploitation courante

**Mettre à jour la démo** : `git push` sur la branche suivie. Render rebuild et redéploie
(`autoDeploy: true` dans `render.yaml`).

**Remettre la démo à zéro** : Render → **Manual Deploy → Clear build cache & deploy**,
ou simplement redémarrer le service : avec `SEED_ON_BOOT=1`, le contenu est reconstruit.

**Console Rails** : l'onglet **Shell** de Render (`./bin/rails console`, `./bin/rails db:seed`)
n'est proposé que sur les instances payantes. Sur le plan Free, passer par un redémarrage avec
`SEED_ON_BOOT=1`, ou reproduire le cas en local avec le conteneur (§6).

**Avant une démonstration** : ouvrir le site 2 minutes avant. Le premier appel après la mise en
veille prend jusqu'à 1 min ; les suivants sont immédiats.

---

## 6. Tester l'image en local avant de pousser

```bash
docker build -t ppg-demo .
docker run --rm -p 3999:3000 \
  -e SECRET_KEY_BASE=$(openssl rand -hex 64) \
  -e DEMO_SQLITE=1 -e SEED_ON_BOOT=1 -e FORCE_SSL=0 \
  -e ADMIN_EMAIL=demo@exemple.fr -e ADMIN_PASSWORD='mot-de-passe-demo-tres-long' \
  ppg-demo
```

Puis `http://localhost:3999`. Deux détails attendus en local :

- `config.assume_ssl = true` reste actif : les URL générées (images, redirections) sont en
  `https://localhost:3999`, donc certaines ressources ne se chargent pas dans le navigateur.
  C'est normal sans terminaison TLS — sur Render, le proxy fait le travail.
- `FORCE_SSL=0` sert **uniquement** à ce test local. Ne jamais poser cette variable sur Render.

---

## 7. Conserver les modifications saisies par le garage

Le disque de l'offre gratuite étant éphémère, deux étapes sont nécessaires :

1. **Base persistante.** Supprimer `DEMO_SQLITE` et pointer vers un MySQL managé gratuit
   (Aiven, TiDB Cloud Serverless, Clever Cloud plan *DEV*) avec les variables
   `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`.
   Si le fournisseur impose TLS, ajouter `ssl_mode: required` au bloc `default` de
   `config/database.yml`. Le schéma utilise des clés étrangères : vérifier qu'elles sont
   supportées (OK chez Aiven ; TiDB les gère depuis la v8).
2. **Images persistantes.** Sinon, après un redéploiement, la base référencera des fichiers
   absents. Ajouter `gem "aws-sdk-s3", require: false`, déclarer un service S3 dans
   `config/storage.yml` (Cloudflare R2 : 10 Go gratuits ; Backblaze B2 : 10 Go) et remplacer
   `config.active_storage.service = :local` par
   `ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym` dans `config/environments/production.rb`.

Puis passer `SEED_ON_BOOT=0` et redéployer : le contenu saisi survit aux redémarrages.

Sans ces deux étapes, laisser `SEED_ON_BOOT=1` et prévenir le garage que la démo se réinitialise.

---

## 8. Dépannage

| Symptôme | Cause | Correctif |
|---|---|---|
| Build échoue sur `bundle install` | `Gemfile.lock` non committé après ajout de `sqlite3` | `bundle lock` puis committer le lock |
| `Missing encryption key to decrypt file with` | Ni `SECRET_KEY_BASE` ni `RAILS_MASTER_KEY` | Définir `SECRET_KEY_BASE` |
| `ActiveRecord::NoDatabaseError` / connexion MySQL refusée au boot | `DEMO_SQLITE` absent ou ≠ `1` | Ajouter `DEMO_SQLITE=1` et redéployer |
| Déploiement « unhealthy » | Health check mal réglé | `Health Check Path` = `/up` |
| Images cassées après un redéploiement | Disque éphémère + `SEED_ON_BOOT=0` | Repasser `SEED_ON_BOOT=1` et redémarrer, ou §7 |
| Le service redémarre en boucle, logs tronqués | Dépassement des 512 Mo | `WEB_CONCURRENCY=1`, `RAILS_MAX_THREADS=3` |
| Première requête très lente | Mise en veille du plan Free | Réveiller le site avant la démo |
| Boucle de redirection HTTPS | `FORCE_SSL=0` posé par erreur sur Render | Supprimer la variable |
| `Vips::Error` sur une image | `libvips` absent | Vérifier que le paquet est installé dans l'étage `base` du `Dockerfile` |

Logs en direct : onglet **Logs** du service, ou `render logs -r <service>` avec le CLI Render.

---

## 9. Coût, limites, fin de vie

- **0 €** : plan Free Render, pas de base managée, pas de domaine.
- Limites acceptées : veille après 15 min, 512 Mo de RAM, 0,1 CPU, disque éphémère,
  URL en `onrender.com`, quota mensuel d'heures d'instance gratuites partagé entre services.
- Fin de la démo : Render → **Settings → Delete Web Service**. Si les fichiers de démo ne
  doivent pas rester dans la branche de production, déployer depuis une branche `demo` dédiée
  (changer `branch:` dans `render.yaml`) et la supprimer ensuite.

**Pour une vraie mise en production** : instance payante sans veille, MySQL managé avec
sauvegardes, stockage objet, nom de domaine + certificat, SMTP si des notifications de
formulaire sont ajoutées, mot de passe admin renouvelé, et suppression des variables
`DEMO_SQLITE` / `SEED_ON_BOOT`.
