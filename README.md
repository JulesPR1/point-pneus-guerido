# Point Pneus Guerido — refonte

Refonte complète de [point-pneus-guerido.com](https://www.point-pneus-guerido.com/) sous forme
d'une application **Ruby on Rails 8** avec un **mini-CMS administrable**.

Le site public est intégralement rendu à partir des données du CMS : aucun contenu n'est écrit
en dur dans les vues.

- **Ruby** 4.0.5 · **Rails** 8.1 · **MySQL** · Active Storage · Hotwire (Turbo + Stimulus)
- Aucune dépendance npm, aucune gem superflue : la CSS est écrite à la main, le JavaScript tient
  en quatre contrôleurs Stimulus, les polices sont auto-hébergées.

## Documentation

| Document | Contenu |
|---|---|
| [`docs/AUDIT.md`](docs/AUDIT.md) | Audit du site existant : arborescence, contenus, formulaires, médias, décisions de reprise |
| [`docs/DESIGN.md`](docs/DESIGN.md) | Direction artistique et design system |
| [`docs/CMS.md`](docs/CMS.md) | Fonctionnement du CMS : modèle de données, types de sections, formulaires |
| [`docs/CORRECTIONS.md`](docs/CORRECTIONS.md) | Passe de correction éditoriale : affirmations retirées, conditionnées, et points à trancher avec le garage |
| [`docs/DEPLOIEMENT-DEMO.md`](docs/DEPLOIEMENT-DEMO.md) | Manuel de mise en ligne de la démo gratuite sur Render (Docker, SQLite, blueprint) |

## Démarrage

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Le seed exige MySQL accessible. Les identifiants par défaut sont lus dans
`config/database.yml` (`DATABASE_USERNAME`, `DATABASE_PASSWORD`, `DATABASE_HOST`).

### Compte administrateur

Le seed crée un compte à partir des variables d'environnement :

```bash
ADMIN_EMAIL=vous@exemple.fr ADMIN_PASSWORD='un-mot-de-passe-long' bin/rails db:seed
```

Sans elles, le compte est `admin@point-pneus-guerido.com` / `changez-ce-mot-de-passe`
— **à changer avant toute mise en ligne**.

Le backoffice est sur `/admin`. Aucune route sous `/admin` n'est accessible sans session.

## Tests

```bash
bin/rails test       # modèles + intégration
bin/rails test:system  # parcours navigateur (Chrome headless)
bin/rails test:all
```

La suite couvre les validations et l'ordonnancement des modèles, la validation serveur et
l'enregistrement des formulaires, la protection et le CRUD du backoffice, le rendu du site
public (ordre des sections, sections masquées, brouillons, SEO, échappement) et le responsive.

## Qualité

```bash
bin/rubocop      # style (rubocop-rails-omakase)
bin/brakeman     # analyse de sécurité statique
bundle exec bundler-audit check --update
```

## Organisation du code

```
app/models/section_kind.rb       registre des types de sections (le page builder)
app/models/form_definition.rb    registre des formulaires publics
app/models/concerns/positionable.rb  ordonnancement partagé sections / éléments
app/views/sections/              un partiel par type de section
app/views/admin/                 backoffice
app/assets/stylesheets/tokens.css design system (variables, composants)
db/seeds.rb                      contenu initial issu de l'audit
```

## Notes de déploiement

- Les variantes d'images sont générées à la demande par Active Storage (libvips).
  En production, prévoir un stockage persistant (`config/storage.yml`) et un job runner.
- `SECRET_KEY_BASE` et les identifiants de base de données passent par l'environnement.
- `robots.txt` interdit `/admin` et `/demandes` ; `sitemap.xml` est généré depuis les pages publiées.
- Le domaine du sitemap est celui de la requête ; l'URL absolue dans `public/robots.txt`
  est à ajuster si le domaine change.
