# frozen_string_literal: true

FactoryBot.define do
  factory :passenger do
    association :reservation
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    document_type { "rut" }
    document_number { "12345678-9" }
    sequence(:seat_number) { |n| "1-#{n}A" }
  end
end
