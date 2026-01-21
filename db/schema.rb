# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_21_224717) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "buses", force: :cascade do |t|
    t.string "name"
    t.string "bus_type"
    t.string "plate_number"
    t.jsonb "seat_layout"
    t.integer "total_seats"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fares", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.string "seat_class"
    t.string "currency"
    t.integer "base_price_cents"
    t.jsonb "pricing_rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_fares_on_trip_id"
  end

  create_table "passengers", force: :cascade do |t|
    t.bigint "reservation_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "document_type"
    t.string "document_number"
    t.string "seat_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_passengers_on_reservation_id"
  end

  create_table "payment_intents", force: :cascade do |t|
    t.bigint "reservation_id", null: false
    t.string "provider"
    t.string "status"
    t.integer "amount_cents"
    t.string "currency"
    t.string "external_id"
    t.jsonb "metadata"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_payment_intents_on_reservation_id"
  end

  create_table "reservation_seats", force: :cascade do |t|
    t.bigint "reservation_id", null: false
    t.string "seat_number"
    t.string "seat_class"
    t.integer "price_cents"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_reservation_seats_on_reservation_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.string "status"
    t.datetime "hold_expires_at"
    t.string "locator_code"
    t.string "contact_email"
    t.string "contact_phone"
    t.integer "total_amount_cents"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locator_code"], name: "index_reservations_on_locator_code", unique: true
    t.index ["trip_id"], name: "index_reservations_on_trip_id"
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "origin_terminal_id", null: false
    t.bigint "destination_terminal_id", null: false
    t.integer "distance_km"
    t.integer "duration_minutes"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_terminal_id"], name: "index_routes_on_destination_terminal_id"
    t.index ["origin_terminal_id", "destination_terminal_id"], name: "index_routes_on_origin_terminal_id_and_destination_terminal_id", unique: true
    t.index ["origin_terminal_id"], name: "index_routes_on_origin_terminal_id"
  end

  create_table "seats", force: :cascade do |t|
    t.bigint "bus_id", null: false
    t.string "seat_number"
    t.string "seat_class"
    t.integer "floor"
    t.integer "row_number"
    t.integer "column_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bus_id"], name: "index_seats_on_bus_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "terminals", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_terminals_on_code", unique: true
  end

  create_table "trips", force: :cascade do |t|
    t.bigint "route_id", null: false
    t.bigint "bus_id", null: false
    t.datetime "departure_at", null: false
    t.datetime "arrival_at", null: false
    t.string "status", default: "scheduled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bus_id"], name: "index_trips_on_bus_id"
    t.index ["departure_at"], name: "index_trips_on_departure_at"
    t.index ["route_id", "departure_at"], name: "index_trips_on_route_id_and_departure_at"
    t.index ["route_id"], name: "index_trips_on_route_id"
    t.index ["status"], name: "index_trips_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.string "name"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "fares", "trips"
  add_foreign_key "passengers", "reservations"
  add_foreign_key "payment_intents", "reservations"
  add_foreign_key "reservation_seats", "reservations"
  add_foreign_key "reservations", "trips"
  add_foreign_key "routes", "terminals", column: "destination_terminal_id"
  add_foreign_key "routes", "terminals", column: "origin_terminal_id"
  add_foreign_key "seats", "buses"
  add_foreign_key "sessions", "users"
  add_foreign_key "trips", "buses"
  add_foreign_key "trips", "routes"
end
