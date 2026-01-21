# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Reservations" do
  let(:trip) { create(:trip) }

  describe "POST /api/reservations" do
    context "with valid seats" do
      it "creates a held reservation" do
        seat_numbers = trip.bus.seats.first(2).map(&:seat_number)

        post "/api/reservations", params: {
          trip_id: trip.id,
          seat_numbers: seat_numbers,
          contact_email: "test@example.com",
          contact_phone: "+56912345678"
        }

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["reservation"]["status"]).to eq("held")
        expect(json["reservation"]["locator_code"]).to be_present
        expect(json["reservation"]["seats"].count).to eq(2)
      end
    end

    context "with unavailable seats" do
      before do
        existing = create(:reservation, trip: trip)
        create(:reservation_seat, reservation: existing, seat_number: trip.bus.seats.first.seat_number)
      end

      it "returns conflict error" do
        post "/api/reservations", params: {
          trip_id: trip.id,
          seat_numbers: [trip.bus.seats.first.seat_number]
        }

        expect(response).to have_http_status(:conflict)
      end
    end
  end

  describe "GET /api/reservations/:locator" do
    let(:reservation) { create(:reservation, trip: trip) }

    before do
      create(:reservation_seat, reservation: reservation, seat_number: trip.bus.seats.first.seat_number)
    end

    it "returns reservation details" do
      get "/api/reservations/#{reservation.locator_code}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["reservation"]["locator_code"]).to eq(reservation.locator_code)
    end

    it "returns 404 for invalid locator" do
      get "/api/reservations/INVALID"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/reservations/:locator" do
    let(:reservation) { create(:reservation, trip: trip) }

    before do
      create(:reservation_seat, reservation: reservation, seat_number: trip.bus.seats.first.seat_number)
    end

    it "updates contact information" do
      patch "/api/reservations/#{reservation.locator_code}", params: {
        contact_email: "new@example.com",
        contact_phone: "+56987654321"
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["reservation"]["contact"]["email"]).to eq("new@example.com")
    end

    it "updates passenger information" do
      patch "/api/reservations/#{reservation.locator_code}", params: {
        passengers: [
          {
            first_name: "Juan",
            last_name: "Pérez",
            document_type: "rut",
            document_number: "12345678-9",
            seat_number: trip.bus.seats.first.seat_number
          }
        ]
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["reservation"]["passengers"].first["full_name"]).to eq("Juan Pérez")
    end
  end

  describe "POST /api/reservations/:locator/checkout" do
    let(:reservation) { create(:reservation, trip: trip) }

    before do
      create(:reservation_seat, reservation: reservation, seat_number: trip.bus.seats.first.seat_number)
      create(:passenger, reservation: reservation, seat_number: trip.bus.seats.first.seat_number)
      reservation.update!(contact_email: "test@example.com", contact_phone: "+56912345678")
    end

    it "creates a payment intent" do
      post "/api/reservations/#{reservation.locator_code}/checkout"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["payment_intent"]["status"]).to eq("created")
      expect(json["payment_intent"]["id"]).to be_present
    end
  end

  describe "DELETE /api/reservations/:locator" do
    let!(:reservation) { create(:reservation, trip: trip) }
    let!(:seat) { create(:reservation_seat, reservation: reservation, seat_number: trip.bus.seats.first.seat_number) }

    it "cancels the reservation" do
      delete "/api/reservations/#{reservation.reload.locator_code}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["reservation"]["status"]).to eq("cancelled")
    end

    context "when reservation is confirmed" do
      before do
        reservation.update!(status: "confirmed")
      end

      it "returns unprocessable_content error" do
        delete "/api/reservations/#{reservation.reload.locator_code}"

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
