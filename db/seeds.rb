# frozen_string_literal: true

# Posku Bus Ticket Platform - Seed Data
# =====================================
# This creates realistic sample data for the bus ticket booking platform.

puts "🚌 Posku Seed Data"
puts "=" * 50

# Helper methods
def print_progress(message, count = nil)
  output = count ? "   ✓ #{message}: #{count}" : "   → #{message}..."
  puts output
end

# Chilean RUT generator (valid format with verification digit)
def generate_rut
  base = rand(5_000_000..25_000_000)
  digits = base.to_s.chars.map(&:to_i).reverse
  factors = [2, 3, 4, 5, 6, 7]
  sum = digits.each_with_index.sum { |d, i| d * factors[i % 6] }
  remainder = 11 - (sum % 11)
  dv = case remainder
       when 11 then "0"
       when 10 then "K"
       else remainder.to_s
       end
  "#{base.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}-#{dv}"
end

# Clear existing data in development
if Rails.env.development?
  puts "\n🧹 Cleaning database..."
  [PaymentIntent, Passenger, ReservationSeat, Reservation, Fare, Trip, Seat, Bus, Route, Terminal, Session, User].each(&:delete_all)
end

# ============================================
# ADMIN USER
# ============================================
puts "\n👤 Creating admin user..."
admin = User.find_or_create_by!(email_address: "admin@posku.cl") do |u|
  u.password = "password123"
  u.name = "Administrador Posku"
  u.admin = true
end
print_progress "Admin user", admin.email_address

# ============================================
# TERMINALS
# ============================================
puts "\n🏢 Creating terminals..."

terminals_data = [
  # Santiago Metropolitan Region (main hub)
  { name: "Terminal Alameda", city: "Santiago", code: "SCL", latitude: -33.4489, longitude: -70.6693 },
  { name: "Terminal San Borja", city: "Santiago", code: "SBO", latitude: -33.4530, longitude: -70.6570 },
  { name: "Terminal Pajaritos", city: "Santiago", code: "PAJ", latitude: -33.4409, longitude: -70.7280 },
  
  # Coastal Region
  { name: "Terminal Rodoviario", city: "Viña del Mar", code: "VIN", latitude: -33.0153, longitude: -71.5503 },
  { name: "Terminal Rodoviario", city: "Valparaíso", code: "VAL", latitude: -33.0472, longitude: -71.6127 },
  
  # Central-South
  { name: "Terminal O'Higgins", city: "Rancagua", code: "RAN", latitude: -34.1708, longitude: -70.7444 },
  { name: "Terminal de Buses", city: "Talca", code: "TLC", latitude: -35.4264, longitude: -71.6554 },
  { name: "Terminal María Teresa", city: "Chillán", code: "CHI", latitude: -36.6066, longitude: -72.1034 },
  
  # Bio Bio Region
  { name: "Terminal Collao", city: "Concepción", code: "CCP", latitude: -36.8201, longitude: -73.0444 },
  { name: "Terminal de Buses", city: "Los Ángeles", code: "LSA", latitude: -37.4693, longitude: -72.3536 },
  
  # Araucanía
  { name: "Terminal Rodoviario", city: "Temuco", code: "ZCO", latitude: -38.7359, longitude: -72.5904 },
  { name: "Terminal de Buses", city: "Villarrica", code: "ZAL", latitude: -39.2854, longitude: -72.2279 },
  
  # Los Ríos & Los Lagos
  { name: "Terminal de Buses", city: "Valdivia", code: "ZLR", latitude: -39.8196, longitude: -73.2424 },
  { name: "Terminal de Buses", city: "Osorno", code: "ZOS", latitude: -40.5729, longitude: -73.1358 },
  { name: "Terminal de Buses", city: "Puerto Montt", code: "PMC", latitude: -41.4717, longitude: -72.9369 },
  
  # Norte Chico
  { name: "Terminal de Buses", city: "La Serena", code: "LSC", latitude: -29.9027, longitude: -71.2519 },
  { name: "Terminal de Buses", city: "Coquimbo", code: "COQ", latitude: -29.9533, longitude: -71.3436 },
  
  # Norte Grande
  { name: "Terminal de Buses", city: "Antofagasta", code: "ANF", latitude: -23.6509, longitude: -70.3975 },
  { name: "Terminal de Buses", city: "Iquique", code: "IQQ", latitude: -20.2208, longitude: -70.1431 },
  { name: "Terminal de Buses", city: "Arica", code: "ARI", latitude: -18.4783, longitude: -70.3126 }
]

terminals = terminals_data.map do |data|
  Terminal.create!(data.merge(active: true))
end

terminals_by_code = terminals.index_by(&:code)
print_progress "Terminals created", terminals.count

# ============================================
# ROUTES
# ============================================
puts "\n🛣️  Creating routes..."

# Define routes with realistic distances and durations
routes_data = [
  # === SANTIAGO HUB - SHORT DISTANCE (Coast) ===
  { origin: "SCL", destination: "VIN", distance_km: 120, duration_minutes: 90 },
  { origin: "SCL", destination: "VAL", distance_km: 130, duration_minutes: 100 },
  { origin: "SBO", destination: "VIN", distance_km: 118, duration_minutes: 85 },
  { origin: "SBO", destination: "VAL", distance_km: 128, duration_minutes: 95 },
  { origin: "PAJ", destination: "VIN", distance_km: 115, duration_minutes: 80 },
  { origin: "VIN", destination: "VAL", distance_km: 10, duration_minutes: 20 },
  
  # === SANTIAGO HUB - CENTRAL SOUTH ===
  { origin: "SCL", destination: "RAN", distance_km: 87, duration_minutes: 75 },
  { origin: "SCL", destination: "TLC", distance_km: 255, duration_minutes: 180 },
  { origin: "SCL", destination: "CHI", distance_km: 400, duration_minutes: 300 },
  { origin: "SBO", destination: "RAN", distance_km: 85, duration_minutes: 70 },
  { origin: "SBO", destination: "TLC", distance_km: 253, duration_minutes: 175 },
  
  # === SANTIAGO HUB - BIO BIO ===
  { origin: "SCL", destination: "CCP", distance_km: 500, duration_minutes: 360 },
  { origin: "SCL", destination: "LSA", distance_km: 520, duration_minutes: 390 },
  { origin: "SBO", destination: "CCP", distance_km: 498, duration_minutes: 355 },
  
  # === SANTIAGO HUB - ARAUCANÍA ===
  { origin: "SCL", destination: "ZCO", distance_km: 680, duration_minutes: 480 },
  { origin: "SCL", destination: "ZAL", distance_km: 780, duration_minutes: 540 },
  { origin: "SBO", destination: "ZCO", distance_km: 678, duration_minutes: 475 },
  
  # === SANTIAGO HUB - LOS LAGOS ===
  { origin: "SCL", destination: "ZLR", distance_km: 840, duration_minutes: 600 },
  { origin: "SCL", destination: "ZOS", distance_km: 920, duration_minutes: 660 },
  { origin: "SCL", destination: "PMC", distance_km: 1020, duration_minutes: 720 },
  { origin: "SBO", destination: "PMC", distance_km: 1018, duration_minutes: 715 },
  
  # === SANTIAGO HUB - NORTE CHICO ===
  { origin: "SCL", destination: "LSC", distance_km: 470, duration_minutes: 360 },
  { origin: "SCL", destination: "COQ", distance_km: 460, duration_minutes: 350 },
  { origin: "SBO", destination: "LSC", distance_km: 468, duration_minutes: 355 },
  
  # === SANTIAGO HUB - NORTE GRANDE ===
  { origin: "SCL", destination: "ANF", distance_km: 1350, duration_minutes: 1080 },
  { origin: "SCL", destination: "IQQ", distance_km: 1850, duration_minutes: 1440 },
  { origin: "SCL", destination: "ARI", distance_km: 2050, duration_minutes: 1560 },
  
  # === RETURN ROUTES - Coast ===
  { origin: "VIN", destination: "SCL", distance_km: 120, duration_minutes: 90 },
  { origin: "VAL", destination: "SCL", distance_km: 130, duration_minutes: 100 },
  { origin: "VIN", destination: "SBO", distance_km: 118, duration_minutes: 85 },
  { origin: "VAL", destination: "SBO", distance_km: 128, duration_minutes: 95 },
  { origin: "VAL", destination: "VIN", distance_km: 10, duration_minutes: 20 },
  
  # === RETURN ROUTES - South ===
  { origin: "RAN", destination: "SCL", distance_km: 87, duration_minutes: 75 },
  { origin: "TLC", destination: "SCL", distance_km: 255, duration_minutes: 180 },
  { origin: "CHI", destination: "SCL", distance_km: 400, duration_minutes: 300 },
  { origin: "CCP", destination: "SCL", distance_km: 500, duration_minutes: 360 },
  { origin: "ZCO", destination: "SCL", distance_km: 680, duration_minutes: 480 },
  { origin: "PMC", destination: "SCL", distance_km: 1020, duration_minutes: 720 },
  
  # === RETURN ROUTES - North ===
  { origin: "LSC", destination: "SCL", distance_km: 470, duration_minutes: 360 },
  { origin: "ANF", destination: "SCL", distance_km: 1350, duration_minutes: 1080 },
  
  # === INTER-REGIONAL SOUTH ===
  { origin: "CCP", destination: "ZCO", distance_km: 280, duration_minutes: 210 },
  { origin: "ZCO", destination: "CCP", distance_km: 280, duration_minutes: 210 },
  { origin: "ZCO", destination: "ZAL", distance_km: 90, duration_minutes: 75 },
  { origin: "ZAL", destination: "ZCO", distance_km: 90, duration_minutes: 75 },
  { origin: "ZCO", destination: "PMC", distance_km: 340, duration_minutes: 270 },
  { origin: "PMC", destination: "ZCO", distance_km: 340, duration_minutes: 270 },
  { origin: "ZOS", destination: "PMC", distance_km: 100, duration_minutes: 75 },
  { origin: "PMC", destination: "ZOS", distance_km: 100, duration_minutes: 75 },
  
  # === INTER-REGIONAL NORTH ===
  { origin: "LSC", destination: "COQ", distance_km: 15, duration_minutes: 20 },
  { origin: "COQ", destination: "LSC", distance_km: 15, duration_minutes: 20 },
  { origin: "LSC", destination: "ANF", distance_km: 880, duration_minutes: 720 },
  { origin: "ANF", destination: "IQQ", distance_km: 500, duration_minutes: 360 },
  { origin: "IQQ", destination: "ARI", distance_km: 310, duration_minutes: 240 }
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
print_progress "Routes created", routes.count

# ============================================
# BUSES
# ============================================
puts "\n🚌 Creating buses..."

# Bus layouts
def create_layout(type, config)
  case type
  when :semi_cama
    # 2+1 configuration, 2 floors
    {
      "type" => "semi_cama",
      "floors" => [
        {
          "floor" => 1,
          "rows" => (1..config[:floor1_rows]).map do |row|
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
          "rows" => (1..config[:floor2_rows]).map do |row|
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
  when :salon_cama
    # Premium 2+1 configuration
    {
      "type" => "salon_cama",
      "floors" => [
        {
          "floor" => 1,
          "rows" => (1..config[:floor1_rows]).map do |row|
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
          "rows" => (1..config[:floor2_rows]).map do |row|
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
  when :classic
    # Economy 2+2 configuration, single floor
    {
      "type" => "classic",
      "floors" => [
        {
          "floor" => 1,
          "rows" => (1..config[:rows]).map do |row|
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
  when :premium
    # Premium cama with 1+1 on first floor
    {
      "type" => "premium",
      "floors" => [
        {
          "floor" => 1,
          "rows" => (1..config[:floor1_rows]).map do |row|
            {
              "row" => row,
              "seats" => [
                { "col" => "A", "class" => "premium" },
                nil,
                nil,
                { "col" => "B", "class" => "premium" }
              ]
            }
          end
        },
        {
          "floor" => 2,
          "rows" => (1..config[:floor2_rows]).map do |row|
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
  end
end

buses_data = [
  # Semi-cama fleet (most common)
  { name: "Pullman SC-001", bus_type: "semi_cama", plate_number: "BJXR-45", layout_type: :semi_cama, config: { floor1_rows: 10, floor2_rows: 10 }, total_seats: 50 },
  { name: "Pullman SC-002", bus_type: "semi_cama", plate_number: "CGHT-78", layout_type: :semi_cama, config: { floor1_rows: 10, floor2_rows: 10 }, total_seats: 50 },
  { name: "Pullman SC-003", bus_type: "semi_cama", plate_number: "DFKL-12", layout_type: :semi_cama, config: { floor1_rows: 10, floor2_rows: 10 }, total_seats: 50 },
  { name: "Pullman SC-004", bus_type: "semi_cama", plate_number: "EWRT-34", layout_type: :semi_cama, config: { floor1_rows: 10, floor2_rows: 10 }, total_seats: 50 },
  { name: "Pullman SC-005", bus_type: "semi_cama", plate_number: "FGHJ-56", layout_type: :semi_cama, config: { floor1_rows: 10, floor2_rows: 10 }, total_seats: 50 },
  { name: "Pullman SC-006", bus_type: "semi_cama", plate_number: "GHJK-89", layout_type: :semi_cama, config: { floor1_rows: 10, floor2_rows: 10 }, total_seats: 50 },
  
  # Salon Cama fleet (premium)
  { name: "Premium SL-001", bus_type: "salon_cama", plate_number: "HJKL-23", layout_type: :salon_cama, config: { floor1_rows: 8, floor2_rows: 8 }, total_seats: 40 },
  { name: "Premium SL-002", bus_type: "salon_cama", plate_number: "JKLM-45", layout_type: :salon_cama, config: { floor1_rows: 8, floor2_rows: 8 }, total_seats: 40 },
  { name: "Premium SL-003", bus_type: "salon_cama", plate_number: "KLMN-67", layout_type: :salon_cama, config: { floor1_rows: 8, floor2_rows: 8 }, total_seats: 40 },
  { name: "Premium SL-004", bus_type: "salon_cama", plate_number: "LMNP-89", layout_type: :salon_cama, config: { floor1_rows: 8, floor2_rows: 8 }, total_seats: 40 },
  
  # Classic fleet (economy, short routes)
  { name: "Express CL-001", bus_type: "classic", plate_number: "MNPQ-12", layout_type: :classic, config: { rows: 11 }, total_seats: 44 },
  { name: "Express CL-002", bus_type: "classic", plate_number: "NPQR-34", layout_type: :classic, config: { rows: 11 }, total_seats: 44 },
  { name: "Express CL-003", bus_type: "classic", plate_number: "PQRS-56", layout_type: :classic, config: { rows: 11 }, total_seats: 44 },
  { name: "Express CL-004", bus_type: "classic", plate_number: "QRST-78", layout_type: :classic, config: { rows: 11 }, total_seats: 44 },
  
  # Premium fleet (long distance luxury)
  { name: "Suite PR-001", bus_type: "premium", plate_number: "RSTU-90", layout_type: :premium, config: { floor1_rows: 6, floor2_rows: 8 }, total_seats: 28 },
  { name: "Suite PR-002", bus_type: "premium", plate_number: "STUV-11", layout_type: :premium, config: { floor1_rows: 6, floor2_rows: 8 }, total_seats: 28 }
]

buses = buses_data.map do |data|
  layout = create_layout(data[:layout_type], data[:config])
  bus = Bus.create!(
    name: data[:name],
    bus_type: data[:bus_type],
    plate_number: data[:plate_number],
    seat_layout: layout,
    total_seats: data[:total_seats],
    active: true
  )
  bus.generate_seats_from_layout!
  bus
end
print_progress "Buses created", buses.count

# ============================================
# TRIPS AND FARES
# ============================================
puts "\n📅 Creating trips and fares..."

# Base prices per seat class (CLP)
BASE_PRICES = {
  "classic" => 6000,
  "semi_cama" => 10000,
  "salon_cama" => 18000,
  "premium" => 28000
}.freeze

# Distance multipliers
DISTANCE_MULTIPLIERS = {
  (0..100) => 1.0,
  (101..200) => 1.3,
  (201..400) => 1.6,
  (401..700) => 2.0,
  (701..1000) => 2.5,
  (1001..1500) => 3.2,
  (1501..Float::INFINITY) => 4.0
}.freeze

def get_distance_multiplier(distance)
  DISTANCE_MULTIPLIERS.find { |range, _| range.include?(distance) }&.last || 1.0
end

# Departure schedules by route type
SCHEDULES = {
  short: [ # < 2 hours
    { hour: 6, minute: 0 }, { hour: 6, minute: 30 }, { hour: 7, minute: 0 }, { hour: 7, minute: 30 },
    { hour: 8, minute: 0 }, { hour: 8, minute: 30 }, { hour: 9, minute: 0 }, { hour: 9, minute: 30 },
    { hour: 10, minute: 0 }, { hour: 10, minute: 30 }, { hour: 11, minute: 0 }, { hour: 11, minute: 30 },
    { hour: 12, minute: 0 }, { hour: 12, minute: 30 }, { hour: 13, minute: 0 }, { hour: 13, minute: 30 },
    { hour: 14, minute: 0 }, { hour: 14, minute: 30 }, { hour: 15, minute: 0 }, { hour: 15, minute: 30 },
    { hour: 16, minute: 0 }, { hour: 16, minute: 30 }, { hour: 17, minute: 0 }, { hour: 17, minute: 30 },
    { hour: 18, minute: 0 }, { hour: 18, minute: 30 }, { hour: 19, minute: 0 }, { hour: 19, minute: 30 },
    { hour: 20, minute: 0 }, { hour: 20, minute: 30 }, { hour: 21, minute: 0 }, { hour: 21, minute: 30 },
    { hour: 22, minute: 0 }, { hour: 22, minute: 30 }
  ],
  medium: [ # 2-6 hours
    { hour: 6, minute: 0 }, { hour: 7, minute: 30 }, { hour: 8, minute: 0 }, { hour: 9, minute: 30 },
    { hour: 10, minute: 0 }, { hour: 11, minute: 30 }, { hour: 12, minute: 0 }, { hour: 14, minute: 0 },
    { hour: 15, minute: 30 }, { hour: 17, minute: 0 }, { hour: 18, minute: 30 }, { hour: 20, minute: 0 },
    { hour: 21, minute: 30 }, { hour: 23, minute: 0 }
  ],
  long: [ # 6-12 hours
    { hour: 7, minute: 0 }, { hour: 9, minute: 0 }, { hour: 11, minute: 0 }, { hour: 14, minute: 0 },
    { hour: 17, minute: 0 }, { hour: 20, minute: 0 }, { hour: 22, minute: 0 }, { hour: 23, minute: 30 }
  ],
  overnight: [ # > 12 hours
    { hour: 20, minute: 0 }, { hour: 21, minute: 0 }, { hour: 22, minute: 0 }, { hour: 23, minute: 0 }
  ]
}.freeze

def get_schedule_type(duration_minutes)
  case duration_minutes
  when 0..120 then :short
  when 121..360 then :medium
  when 361..720 then :long
  else :overnight
  end
end

# Select appropriate buses for route
def select_buses_for_route(duration_minutes, all_buses)
  case duration_minutes
  when 0..120
    # Short routes: classic and semi_cama
    all_buses.select { |b| %w[classic semi_cama].include?(b.bus_type) }
  when 121..360
    # Medium routes: semi_cama and salon_cama
    all_buses.select { |b| %w[semi_cama salon_cama].include?(b.bus_type) }
  when 361..720
    # Long routes: salon_cama and some semi_cama
    all_buses.select { |b| %w[semi_cama salon_cama premium].include?(b.bus_type) }
  else
    # Overnight: premium and salon_cama
    all_buses.select { |b| %w[salon_cama premium].include?(b.bus_type) }
  end
end

base_date = Date.current
trip_count = 0
fare_count = 0

# Create trips for the next 14 days (reduced for faster seeding)
days_to_seed = Rails.env.production? ? 14 : 7
(0..days_to_seed).each do |day_offset|
  date = base_date + day_offset.days
  is_weekend = date.saturday? || date.sunday?
  is_friday = date.friday?

  routes.each do |route|
    schedule_type = get_schedule_type(route.duration_minutes)
    schedule = SCHEDULES[schedule_type]
    
    # More trips on popular routes and weekends
    popular_destinations = %w[VIN VAL CCP ZCO PMC LSC]
    is_popular = popular_destinations.include?(route.destination_terminal.code) ||
                 popular_destinations.include?(route.origin_terminal.code)
    
    # Determine number of trips (reduced for faster seeding)
    base_trips = case schedule_type
                 when :short then 5
                 when :medium then 3
                 when :long then 2
                 else 2
                 end
    
    base_trips += 1 if is_popular
    base_trips += 1 if is_weekend || is_friday
    
    trips_count = [base_trips, schedule.size].min
    selected_times = schedule.sample(trips_count).sort_by { |t| [t[:hour], t[:minute]] }
    
    eligible_buses = select_buses_for_route(route.duration_minutes, buses)
    
    selected_times.each do |time|
      bus = eligible_buses.sample
      departure_at = date.to_datetime.change(hour: time[:hour], min: time[:minute])
      arrival_at = departure_at + route.duration_minutes.minutes
      
      trip = Trip.create!(
        route: route,
        bus: bus,
        departure_at: departure_at,
        arrival_at: arrival_at,
        status: "scheduled"
      )
      trip_count += 1
      
      # Create fares
      seat_classes = bus.seats.pluck(:seat_class).uniq
      distance_mult = get_distance_multiplier(route.distance_km)
      
      # Day/time pricing rules
      day_mult = if is_friday then 1.15
                 elsif date.saturday? then 1.25
                 elsif date.sunday? then 1.1
                 else 1.0
                 end
      
      time_mult = case time[:hour]
                  when 6..9 then 1.05   # Morning rush
                  when 17..20 then 1.1  # Evening rush
                  when 22..23 then 0.95 # Night discount
                  else 1.0
                  end
      
      seat_classes.each do |seat_class|
        base = BASE_PRICES[seat_class] || 8000
        price = (base * distance_mult * day_mult * time_mult).round(-2) # Round to nearest 100
        
        Fare.create!(
          trip: trip,
          seat_class: seat_class,
          currency: "CLP",
          base_price_cents: price,
          pricing_rules: {
            "day_multipliers" => { "friday" => 1.15, "saturday" => 1.25, "sunday" => 1.1 },
            "time_multipliers" => { "rush_morning" => 1.05, "rush_evening" => 1.1, "night" => 0.95 }
          }
        )
        fare_count += 1
      end
    end
  end
  
  # Progress indicator
  print "." if day_offset % 3 == 0
end

puts ""
print_progress "Trips created", trip_count
print_progress "Fares created", fare_count

# ============================================
# SAMPLE RESERVATIONS
# ============================================
puts "\n🎫 Creating sample reservations..."

# Chilean names for realistic data
FIRST_NAMES = %w[
  José María Juan Ana Pedro Carmen Carlos Rosa Francisco Isabel
  Luis Teresa Miguel Francisca Antonio Marta Manuel Elena Diego Patricia
  Alejandro Claudia Felipe Valentina Sebastián Camila Nicolás Catalina
  Martín Javiera Benjamín Constanza Tomás Isidora Matías Antonia
  Vicente Sofía Gabriel Fernanda Joaquín Macarena Agustín Daniela
  Maximiliano Paz Cristóbal Trinidad Pablo Florencia Lucas Josefa
].freeze

LAST_NAMES = %w[
  González Muñoz Rojas Díaz Pérez Soto Contreras Silva Martínez Sepúlveda
  Morales Rodríguez López García Hernández Torres Araya Flores Espinoza Valenzuela
  Castillo Tapia Reyes Fuentes Figueroa Jara Vera Cortés Núñez Bravo
  Rivera Carrasco Vega Leiva Pizarro Campos Vargas Sandoval Orellana Gutiérrez
  Saavedra Herrera Arancibia Lagos Poblete Castro Vásquez Alarcón Cáceres Yáñez
].freeze

EMAILS_DOMAINS = %w[gmail.com hotmail.com yahoo.com outlook.com live.cl].freeze

def normalize_for_email(str)
  str.downcase
     .gsub(/á/, 'a').gsub(/é/, 'e').gsub(/í/, 'i').gsub(/ó/, 'o').gsub(/ú/, 'u')
     .gsub(/ñ/, 'n').gsub(/ü/, 'u')
     .gsub(/[^a-z0-9]/, '')
end

def random_email(first_name, last_name)
  fn = normalize_for_email(first_name)
  ln = normalize_for_email(last_name)
  variants = [
    "#{fn}.#{ln}",
    "#{fn}#{ln}",
    "#{fn}.#{ln}#{rand(10..99)}",
    "#{fn[0]}#{ln}",
    "#{fn}#{rand(100..999)}"
  ]
  "#{variants.sample}@#{EMAILS_DOMAINS.sample}"
end

def random_phone
  "+569#{rand(10000000..99999999)}"
end

reservation_count = 0
passenger_count = 0

# Get sample of trips for reservations (limit for speed)
upcoming_trips = Trip.where("departure_at > ? AND departure_at < ?", Time.current, 7.days.from_now)
                     .includes(:bus, :route, :fares)
                     .order("RANDOM()")
                     .limit(100)

upcoming_trips.each do |trip|
  # Determine occupancy rate (higher for popular routes and weekends)
  is_weekend = trip.departure_at.saturday? || trip.departure_at.sunday?
  is_popular = %w[VIN VAL CCP ZCO].include?(trip.route.destination_terminal.code)
  
  base_occupancy = case
                   when is_weekend && is_popular then rand(0.5..0.85)
                   when is_weekend || is_popular then rand(0.3..0.7)
                   else rand(0.1..0.5)
                   end
  
  # Closer departures have higher occupancy
  days_until = (trip.departure_at.to_date - Date.current).to_i
  occupancy_boost = case days_until
                    when 0..2 then 0.2
                    when 3..5 then 0.1
                    else 0
                    end
  
  target_occupancy = [base_occupancy + occupancy_boost, 0.95].min
  
  available_seats = trip.bus.seats.pluck(:seat_number)
  seats_to_fill = (available_seats.size * target_occupancy).to_i
  seats_to_occupy = available_seats.sample(seats_to_fill)
  
  next if seats_to_occupy.empty?
  
  # Group into reservations (1-4 passengers per reservation)
  seats_to_occupy.shuffle.each_slice(rand(1..4)) do |seat_group|
    first_name = FIRST_NAMES.sample
    last_name = LAST_NAMES.sample
    
    reservation = Reservation.create!(
      trip: trip,
      status: "confirmed",
      contact_email: random_email(first_name, last_name),
      contact_phone: random_phone,
      currency: "CLP",
      total_amount_cents: 0
    )
    reservation_count += 1
    
    seat_group.each_with_index do |seat_number, idx|
      seat = trip.bus.seats.find_by(seat_number: seat_number)
      fare = trip.fare_for_seat_class(seat.seat_class)
      
      ReservationSeat.create!(
        reservation: reservation,
        seat_number: seat_number,
        seat_class: seat.seat_class,
        price_cents: fare&.base_price_cents || 10000,
        status: "confirmed"
      )
      
      # Use same last name for group (family/friends)
      p_first = idx == 0 ? first_name : FIRST_NAMES.sample
      p_last = rand < 0.7 ? last_name : LAST_NAMES.sample
      
      Passenger.create!(
        reservation: reservation,
        first_name: p_first,
        last_name: p_last,
        document_type: rand < 0.95 ? "rut" : "passport",
        document_number: generate_rut,
        seat_number: seat_number
      )
      passenger_count += 1
    end
    
    reservation.recalculate_total!
    
    # Create payment intent for confirmed reservations
    PaymentIntent.create!(
      reservation: reservation,
      provider: "fintoc_mock",
      status: "succeeded",
      amount_cents: reservation.total_amount_cents,
      currency: "CLP",
      metadata: { locator_code: reservation.locator_code }
    )
  end
end

print_progress "Reservations created", reservation_count
print_progress "Passengers created", passenger_count

# ============================================
# SUMMARY
# ============================================
puts "\n" + "=" * 50
puts "🎉 Seed completed successfully!"
puts "=" * 50
puts ""
puts "📊 Summary:"
puts "   • Terminals: #{Terminal.count}"
puts "   • Routes: #{Route.count}"
puts "   • Buses: #{Bus.count}"
puts "   • Trips: #{Trip.count}"
puts "   • Fares: #{Fare.count}"
puts "   • Reservations: #{Reservation.count}"
puts "   • Passengers: #{Passenger.count}"
puts ""
puts "🔐 Admin credentials:"
puts "   Email: admin@posku.cl"
puts "   Password: password123"
puts ""
puts "🌐 Access the app at: https://posku.onrender.com"
puts ""
