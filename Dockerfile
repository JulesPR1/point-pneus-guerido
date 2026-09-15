# syntax=docker/dockerfile:1
# Image de déploiement de la démo (voir docs/DEPLOIEMENT-DEMO.md).
# Construction : docker build -t ppg-demo .
# Exécution   : docker run --rm -p 3000:3000 -e SECRET_KEY_BASE=... ppg-demo

ARG RUBY_VERSION=4.0.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# libvips : variantes Active Storage. default-mysql-client : bibliothèque
# cliente MySQL pour mysql2 (parcours MySQL) et console de dépannage.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libjemalloc2 libvips default-mysql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives


# --- étape de construction -------------------------------------------------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git pkg-config default-libmysqlclient-dev libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

# Précompilation du bootsnap puis des assets, sans secret réel.
RUN bundle exec bootsnap precompile app/ lib/ || true
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# --- image finale ----------------------------------------------------------
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp public
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
