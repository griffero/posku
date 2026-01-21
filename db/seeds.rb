# frozen_string_literal: true

# Clear existing data in development
if Rails.env.development?
  puts "Cleaning database..."
  [PaymentIntent, Passenger, ReservationSeat, Reservation, Fare, Trip, Seat, Bus, Route, Terminal, Session, User].each(&:delete_all)
end

puts "Creating admin user..."
admin = User.create!(
  email_address: "admin@posku.cl",
  password: "password123",
  name: "Administrador",
  admin: true
)
puts "Admin created: #{admin.email_address}"

puts "Creating terminals..."
terminals_data = [
  { name: "Terminal Alameda", city: "Santiago", code: "SCL", latitude: -33.4489, longitude: -70.6693 },
  { name: "Terminal San Borja", city: "Santiago", code: "SBO", latitude: -33.4530, longitude: -70.6570 },
  { name: "Terminal Pajaritos", city: "Santiago", code: "PAJ", latitude: -33.4409, longitude: -70.7280 },
  { name: "Terminal Rodoviario", city: "Viña del Mar", code: "VIN", latitude: -33.0153, longitude: -71.5503 },
  { name: "Terminal Rodoviario", city: "Valparaíso", code: "VAL", latitude: -33.0472, longitude: -71.6127 },
  { name: "Terminal Collao", city: "Concepción", code: "CCP", latitude: -36.8201, longitude: -73.0444 },
  { name: "Terminal de Buses", city: "Temuco", code: "ZCO", latitude: -38.7359, longitude: -72.5904 },
  { name: "Terminal de Buses", city: "Puerto Montt", code: "PMC", latitude: -41.4717, longitude: -72.9369 },
  { name: "Terminal de Buses", city: "La Serena", code: "LSC", latitude: -29.9027, longitude: -71.2519 },
  { name: "Terminal de Buses", city: "Antofagasta", code: "ANF", latitude: -23.6509, longitude: -70.3975 },
  { name: "Terminal de Buses", city: "Rancagua", code: "RAN", latitude: -34.1708, longitude: -70.7444 },
  { name: "Terminal de Buses", city: "Talca", code: "TLC", latitude: -35.4264, longitude: -71.6554 },
  { name: "Terminal de Buses", city: "Chillán", code: "CHI", latitude: -36.6066, longitude: -72.1034 }
]

terminals = terminals_data.map do |data|
  Terminal.create!(data.merge(active: true))
end

terminals_by_code = terminals.index_by(&:code)
puts "Created #{terminals.count} terminals"

puts "Creating routes..."
routes_data = [
  # Santiago - Coast
  { origin: "SCL", destination: "VIN", distance_km: 120, duration_minutes: 90 },
  { origin: "SCL", destination: "VAL", distance_km: 130, duration_minutes: 100 },
  { origin: "VIN", destination: "SCL", distance_km: 120, duration_minutes: 90 },
  { origin: "VAL", destination: "SCL", distance_km: 130, duration_minutes: 100 },

  # Santiago - South
  { origin: "SCL", destination: "RAN", distance_km: 87, duration_minutes: 75 },
  { origin: "SCL", destination: "TLC", distance_km: 255, duration_minutes: 180 },
  { origin: "SCL", destination: "CHI", distance_km: 400, duration_minutes: 300 },
  { origin: "SCL", destination: "CCP", distance_km: 500, duration_minutes: 360 },
  { origin: "SCL", destination: "ZCO", distance_km: 680, duration_minutes: 480 },
  { origin: "SCL", destination: "PMC", distance_km: 1000, duration_minutes: 720 },

  # Return routes South
  { origin: "RAN", destination: "SCL", distance_km: 87, duration_minutes: 75 },
  { origin: "TLC", destination: "SCL", distance_km: 255, duration_minutes: 180 },
  { origin: "CCP", destination: "SCL", distance_km: 500, duration_minutes: 360 },
  { origin: "ZCO", destination: "SCL", distance_km: 680, duration_minutes: 480 },
  { origin: "PMC", destination: "SCL", distance_km: 1000, duration_minutes: 720 },

  # Santiago - North
  { origin: "SCL", destination: "LSC", distance_km: 470, duration_minutes: 360 },
  { origin: "SCL", destination: "ANF", distance_km: 1350, duration_minutes: 960 },
  { origin: "LSC", destination: "SCL", distance_km: 470, duration_minutes: 360 },
  { origin: "ANF", destination: "SCL", distance_km: 1350, duration_minutes: 960 },

  # Inter-city south
  { origin: "CCP", destination: "ZCO", distance_km: 180, duration_minutes: 150 },
  { origin: "ZCO", destination: "PMC", distance_km: 320, duration_minutes: 240 }
]

routes = routes_data.map do |data|
  Route.create!(
    origin_terminal: terminals_by_code[data[:origin]],
    destination_terminal: terminals_by_code[data[:destination]],
    distance_km: data[:distance_km],
    duration_minutes: data[:duration_minutes],
    active: true
  )
end
puts "Created #{routes.count} routes"

puts "Creating buses..."
# Semi-cama 2+1 layout (40 seats)
semi_cama_layout = {
  "type" => "semi_cama",
  "floors" => [
    {
      "floor" => 1,
      "rows" => (1..10).map do |row|
        {
          "row" => row,
          "seats" => [
            { "col" => "A", "class" => "semi_cama" },
            { "col" => "B", "class" => "semi_cama" },
            nil,
            { "col" => "C", "class" => "semi_cama" }
          ]
        }
      end
    },
    {
      "floor" => 2,
      "rows" => (1..10).map do |row|
        {
          "row" => row,
          "seats" => [
            { "col" => "A", "class" => "semi_cama" },
            nil,
            { "col" => "B", "class" => "semi_cama" }
          ]
        }
      end
    }
  ]
}

# Salon cama 2+1 layout (32 seats - more spacious)
salon_cama_layout = {
  "type" => "salon_cama",
  "floors" => [
    {
      "floor" => 1,
      "rows" => (1..8).map do |row|
        {
          "row" => row,
          "seats" => [
            { "col" => "A", "class" => "salon_cama" },
            { "col" => "B", "class" => "salon_cama" },
            nil,
            { "col" => "C", "class" => "salon_cama" }
          ]
        }
      end
    },
    {
      "floor" => 2,
      "rows" => (1..8).map do |row|
        {
          "row" => row,
          "seats" => [
            { "col" => "A", "class" => "salon_cama" },
            nil,
            { "col" => "B", "class" => "salon_cama" }
          ]
        }
      end
    }
  ]
}

# Classic 2+2 layout (44 seats)
classic_layout = {
  "type" => "classic",
  "floors" => [
    {
      "floor" => 1,
      "rows" => (1..11).map do |row|
        {
          "row" => row,
          "seats" => [
            { "col" => "A", "class" => "classic" },
            { "col" => "B", "class" => "classic" },
            nil,
            { "col" => "C", "class" => "classic" },
            { "col" => "D", "class" => "classic" }
          ]
        }
      end
    }
  ]
}

buses_data = [
  { name: "Bus SC-001", bus_type: "semi_cama", plate_number: "ABCD-12", seat_layout: semi_cama_layout, total_seats: 50 },
  { name: "Bus SC-002", bus_type: "semi_cama", plate_number: "EFGH-34", seat_layout: semi_cama_layout, total_seats: 50 },
  { name: "Bus SC-003", bus_type: "semi_cama", plate_number: "IJKL-56", seat_layout: semi_cama_layout, total_seats: 50 },
  { name: "Bus SL-001", bus_type: "salon_cama", plate_number: "MNOP-78", seat_layout: salon_cama_layout, total_seats: 40 },
  { name: "Bus SL-002", bus_type: "salon_cama", plate_number: "QRST-90", seat_layout: salon_cama_layout, total_seats: 40 },
  { name: "Bus CL-001", bus_type: "classic", plate_number: "UVWX-11", seat_layout: classic_layout, total_seats: 44 },
  { name: "Bus CL-002", bus_type: "classic", plate_number: "YZAB-22", seat_layout: classic_layout, total_seats: 44 },
  { name: "Bus SC-004", bus_type: "semi_cama", plate_number: "CDEF-33", seat_layout: semi_cama_layout, total_seats: 50 },
  { name: "Bus SL-003", bus_type: "salon_cama", plate_number: "GHIJ-44", seat_layout: salon_cama_layout, total_seats: 40 }
]

buses = buses_data.map do |data|
  bus = Bus.create!(data.merge(active: true))
  bus.generate_seats_from_layout!
  bus
end
puts "Created #{buses.count} buses with seats"

puts "Creating trips and fares..."
# Create trips for the next 14 days
base_date = Date.current

# Price configuration per seat class (in CLP cents)
base_prices = {
  "classic" => 5_000_00,      # $5,000 CLP
  "semi_cama" => 8_000_00,    # $8,000 CLP
  "salon_cama" => 15_000_00   # $15,000 CLP
}

# Price multipliers by route distance
distance_multipliers = {
  (0..100) => 1.0,
  (101..300) => 1.5,
  (301..500) => 2.0,
  (501..800) => 2.5,
  (801..1500) => 3.5
}

def get_distance_multiplier(distance, multipliers)
  multipliers.find { |range, _| range.include?(distance) }&.last || 1.0
end

# Common departure times
departure_times = [
  { hour: 6, minute: 0 },
  { hour: 7, minute: 30 },
  { hour: 8, minute: 0 },
  { hour: 9, minute: 30 },
  { hour: 10, minute: 0 },
  { hour: 11, minute: 30 },
  { hour: 12, minute: 0 },
  { hour: 14, minute: 0 },
  { hour: 15, minute: 30 },
  { hour: 17, minute: 0 },
  { hour: 18, minute: 30 },
  { hour: 20, minute: 0 },
  { hour: 21, minute: 30 },
  { hour: 23, minute: 0 }
]

trip_count = 0
popular_routes = routes.select { |r| %w[VIN VAL CCP ZCO].include?(r.destination_terminal.code) || %w[VIN VAL CCP ZCO].include?(r.origin_terminal.code) }

# Create trips
(0..13).each do |day_offset|
  date = base_date + day_offset.days

  routes.each do |route|
    # Determine number of trips per day based on popularity
    trips_per_day = popular_routes.include?(route) ? rand(4..6) : rand(2..4)

    # Select random departure times
    selected_times = departure_times.sample(trips_per_day).sort_by { |t| [t[:hour], t[:minute]] }

    selected_times.each do |time|
      bus = buses.sample
      departure_at = date.to_datetime.change(hour: time[:hour], min: time[:minute])
      arrival_at = departure_at + route.duration_minutes.minutes

      trip = Trip.create!(
        route: route,
        bus: bus,
        departure_at: departure_at,
        arrival_at: arrival_at,
        status: "scheduled"
      )

      # Create fares for each seat class on this bus
      seat_classes = bus.seats.pluck(:seat_class).uniq
      distance_mult = get_distance_multiplier(route.distance_km, distance_multipliers)

      # Day of week pricing rules
      pricing_rules = {
        "day_multipliers" => {
          "friday" => 1.2,
          "saturday" => 1.3,
          "sunday" => 1.15
        },
        "time_multipliers" => {
          "morning" => 1.0,
          "afternoon" => 1.1,
          "evening" => 1.15,
          "night" => 0.9
        }
      }

      seat_classes.each do |seat_class|
        base_price = (base_prices[seat_class] * distance_mult).round
        Fare.create!(
          trip: trip,
          seat_class: seat_class,
          currency: "CLP",
          base_price_cents: base_price,
          pricing_rules: pricing_rules
        )
      end

      trip_count += 1
    end
  end
end

puts "Created #{trip_count} trips with fares"

# Create some sample reservations with random occupied seats
puts "Creating sample reservations..."
sample_trips = Trip.where("departure_at > ?", Time.current).limit(20)

sample_trips.each do |trip|
  # Randomly occupy 10-40% of seats
  available_seats = trip.bus.seats.pluck(:seat_number)
  seats_to_occupy = available_seats.sample(rand((available_seats.size * 0.1).to_i..(available_seats.size * 0.4).to_i))

  next if seats_to_occupy.empty?

  # Group seats into reservations of 1-3 passengers
  seats_to_occupy.each_slice(rand(1..3)) do |seat_group|
    reservation = Reservation.create!(
      trip: trip,
      status: "confirmed",
      contact_email: "cliente#{rand(1000)}@example.com",
      contact_phone: "+569#{rand(10000000..99999999)}",
      currency: "CLP",
      total_amount_cents: 0
    )

    seat_group.each do |seat_number|
      seat = trip.bus.seats.find_by(seat_number: seat_number)
      fare = trip.fare_for_seat_class(seat.seat_class)

      ReservationSeat.create!(
        reservation: reservation,
        seat_number: seat_number,
        seat_class: seat.seat_class,
        price_cents: fare.base_price_cents,
        status: "confirmed"
      )

      Passenger.create!(
        reservation: reservation,
        first_name: %w[Juan María Carlos Ana Pedro Laura Diego Sofía].sample,
        last_name: %w[González Rodríguez López Martínez García Hernández Pérez Sánchez].sample,
        document_type: "rut",
        document_number: "#{rand(10000000..25000000)}-#{rand(0..9)}",
        seat_number: seat_number
      )
    end

    reservation.recalculate_total!
  end
end

puts "Created sample reservations"
puts "Seed completed successfully!"
puts ""
puts "Admin credentials:"
puts "  Email: admin@posku.cl"
puts "  Password: password123"
