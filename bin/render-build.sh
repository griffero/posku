#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install

# Clean npm cache and reinstall for Linux platform
rm -rf node_modules package-lock.json
npm install --include=optional
npm run build
npm run build:css

# Precompile assets
bundle exec rails assets:precompile

# Clean up old assets
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Run solid_queue and solid_cache migrations on primary database
bundle exec rails db:migrate:all || true

# Seed the database if it's empty
bundle exec rails runner "
  if Terminal.count == 0
    puts 'Seeding database...'
    Rails.application.load_seed
    puts 'Database seeded!'
  else
    puts 'Database already has data, skipping seed.'
  end
"
