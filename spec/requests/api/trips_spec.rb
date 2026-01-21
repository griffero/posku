# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Trips" do
  let(:origin) { create(:terminal, code: "SCL") }
  let(:destination) { create(:terminal, code: "VIN") }
  let(:route) { create(:route, origin_terminal: origin, destination_terminal: destination) }

  describe "GET /api/trips/search" do
    context "with valid parameters" do
      before do
        create(:trip, route: route, departure_at: 1.day.from_now.change(hour: 10), arrival_at: 1.day.from_now.change(hour: 11, min: 30))
        create(:trip, route: route, departure_at: 2.days.from_now.change(hour: 10), arrival_at: 2.days.from_now.change(hour: 11, min: 30))
      end

      it "returns trips for the specified route and date" do
        get "/api/trips/search", params: {
          origin: "SCL",
          destination: "VIN",
          date: 1.day.from_now.to_date.to_s,
          passengers: 1
        }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["trips"].count).to eq(1)
        expect(json["search"]["origin"]["code"]).to eq("SCL")
        expect(json["search"]["destination"]["code"]).to eq("VIN")
      end

      it "includes trip availability information" do
        get "/api/trips/search", params: {
          origin: "SCL",
          destination: "VIN",
          date: 1.day.from_now.to_date.to_s,
          passengers: 1
        }

        json = JSON.parse(response.body)
        trip = json["trips"].first

        expect(trip).to include(
          "id", "departure_at", "arrival_at", "duration_formatted",
          "bus_type_label", "available_seats", "has_availability", "price_from_formatted"
        )
      end
    end

    context "with invalid route" do
      it "returns 404" do
        get "/api/trips/search", params: {
          origin: "INVALID",
          destination: "VIN",
          date: 1.day.from_now.to_date.to_s,
          passengers: 1
        }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/trips/:id" do
    let(:trip) { create(:trip, route: route) }

    it "returns trip details" do
      get "/api/trips/#{trip.id}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["trip"]["id"]).to eq(trip.id)
      expect(json["trip"]["route"]["origin"]["code"]).to eq("SCL")
    end
  end

  describe "GET /api/trips/:id/seats" do
    let(:trip) { create(:trip, route: route) }

    it "returns seat map with availability" do
      get "/api/trips/#{trip.id}/seats"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["trip_id"]).to eq(trip.id)
      expect(json["seats"]).to be_an(Array)
      expect(json["layout"]).to be_present
    end

    it "marks occupied seats correctly" do
      # Create a confirmed reservation
      reservation = create(:reservation, :confirmed, trip: trip)
      first_seat = trip.bus.seats.first
      create(:reservation_seat, :confirmed, reservation: reservation, seat_number: first_seat.seat_number)

      get "/api/trips/#{trip.id}/seats"

      json = JSON.parse(response.body)
      occupied_seat = json["seats"].find { |s| s["seat_number"] == first_seat.seat_number }

      expect(occupied_seat["available"]).to be false
    end
  end
end
