# frozen_string_literal: true

FactoryBot.define do
  factory :terminal do
    sequence(:name) { |n| "Terminal #{n}" }
    sequence(:city) { |n| "Ciudad #{n}" }
    sequence(:code) { |n| "T#{n.to_s.rjust(2, '0')}" }
    latitude { -33.4489 }
    longitude { -70.6693 }
    active { true }
  end
end
