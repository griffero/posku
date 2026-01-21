#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
npm install
npm run build
npm run build:css

# Precompile assets
bundle exec rails assets:precompile

# Clean up old assets
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

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
