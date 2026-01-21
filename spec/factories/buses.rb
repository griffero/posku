# frozen_string_literal: true

FactoryBot.define do
  factory :bus do
    sequence(:name) { |n| "Bus #{n}" }
    bus_type { "semi_cama" }
    sequence(:plate_number) { |n| "ABCD-#{n.to_s.rjust(2, '0')}" }
    total_seats { 10 }
    active { true }
    seat_layout do
      {
        "type" => "semi_cama",
        "floors" => [
          {
            "floor" => 1,
            "rows" => [
              { "row" => 1, "seats" => [{ "col" => "A", "class" => "semi_cama" }, nil, { "col" => "B", "class" => "semi_cama" }] },
              { "row" => 2, "seats" => [{ "col" => "A", "class" => "semi_cama" }, nil, { "col" => "B", "class" => "semi_cama" }] }
            ]
          }
        ]
      }
    end

    after(:create) do |bus|
      bus.generate_seats_from_layout!
    end
  end
end
