# frozen_string_literal: true

FactoryBot.define do
  factory :trip do
    association :route
    association :bus
    departure_at { 1.day.from_now.change(hour: 10) }
    arrival_at { 1.day.from_now.change(hour: 11, min: 30) }
    status { "scheduled" }

    transient do
      with_fare { true }
    end

    after(:create) do |trip, evaluator|
      create(:fare, trip: trip, seat_class: "semi_cama") if evaluator.with_fare
    end
  end
end
