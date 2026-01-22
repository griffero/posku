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
# Force re-seed if RESEED=true or if database is empty
bundle exec rails runner "
  force_reseed = ENV['RESEED'] == 'true'
  
  if force_reseed
    puts 'Force re-seeding database...'
    # Clear existing data
    [PaymentIntent, Passenger, ReservationSeat, Reservation, Fare, Trip, Seat, Bus, Route, Terminal].each do |model|
      model.delete_all rescue nil
    end
    Rails.application.load_seed
    puts 'Database re-seeded!'
  elsif Terminal.count == 0
    puts 'Seeding database...'
    Rails.application.load_seed
    puts 'Database seeded!'
  else
    puts 'Database already has data. Set RESEED=true to force re-seed.'
  end
"
