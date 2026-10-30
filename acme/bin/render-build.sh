#!/usr/bin/env bash
# Build command for an online host (Render, ...): installs the gems, compiles the assets, updates the database.
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails db:migrate
