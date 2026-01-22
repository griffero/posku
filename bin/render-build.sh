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

# Run database migrations (includes Solid Queue tables)
bundle exec rails db:migrate

# Seed the database
# ONE-TIME FORCE RESEED - Remove this after deploy!
bundle exec rails runner "
  puts 'Force re-seeding database with new routes...'
  # Clear existing data (preserving users)
  [PaymentIntent, Passenger, ReservationSeat, Reservation, Fare, Trip, Seat, Bus, Route, Terminal].each do |model|
    model.delete_all rescue nil
  end
  Rails.application.load_seed
  puts 'Database re-seeded successfully!'
"
