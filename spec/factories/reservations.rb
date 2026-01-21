# frozen_string_literal: true

FactoryBot.define do
  factory :reservation do
    association :trip
    status { "held" }
    hold_expires_at { 8.minutes.from_now }
    contact_email { Faker::Internet.email }
    contact_phone { "+56912345678" }
    total_amount_cents { 8000 }
    currency { "CLP" }

    trait :confirmed do
      status { "confirmed" }
      hold_expires_at { nil }
    end

    trait :expired do
      status { "expired" }
      hold_expires_at { 1.hour.ago }
    end
  end
end
