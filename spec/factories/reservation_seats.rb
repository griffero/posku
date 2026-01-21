# frozen_string_literal: true

FactoryBot.define do
  factory :reservation_seat do
    association :reservation
    sequence(:seat_number) { |n| "1-#{n}A" }
    seat_class { "semi_cama" }
    price_cents { 8000 }
    status { "held" }

    trait :confirmed do
      status { "confirmed" }
    end
  end
end
