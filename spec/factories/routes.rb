# frozen_string_literal: true

FactoryBot.define do
  factory :route do
    association :origin_terminal, factory: :terminal
    association :destination_terminal, factory: :terminal
    distance_km { 120 }
    duration_minutes { 90 }
    active { true }
  end
end
