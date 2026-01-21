# frozen_string_literal: true

FactoryBot.define do
  factory :fare do
    association :trip
    seat_class { "semi_cama" }
    currency { "CLP" }
    base_price_cents { 8000 }
    pricing_rules { {} }
  end
end
