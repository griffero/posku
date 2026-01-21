# frozen_string_literal: true

require "rails_helper"

RSpec.describe SeatHoldService do
  let(:trip) { create(:trip) }
  let(:service) { described_class.new(trip) }

  describe "#hold_seats" do
    context "when seats are available" do
      it "creates a reservation with held status" do
        seat_numbers = trip.bus.seats.first(2).map(&:seat_number)

        reservation = service.hold_seats(seat_numbers)

        expect(reservation).to be_persisted
        expect(reservation.status).to eq("held")
        expect(reservation.hold_expires_at).to be_present
        expect(reservation.reservation_seats.count).to eq(2)
      end

      it "sets the correct hold expiration time" do
        seat_numbers = [trip.bus.seats.first.seat_number]

        freeze_time do
          reservation = service.hold_seats(seat_numbers)
          expected_expiry = SeatHoldService::HOLD_DURATION.from_now

          expect(reservation.hold_expires_at).to be_within(1.second).of(expected_expiry)
        end
      end

      it "calculates total price correctly" do
        seat_numbers = trip.bus.seats.first(2).map(&:seat_number)

        reservation = service.hold_seats(seat_numbers)

        expected_total = reservation.reservation_seats.sum(:price_cents)
        expect(reservation.total_amount_cents).to eq(expected_total)
      end

      it "stores contact information" do
        seat_numbers = [trip.bus.seats.first.seat_number]

        reservation = service.hold_seats(
          seat_numbers,
          contact_email: "test@example.com",
          contact_phone: "+56912345678"
        )

        expect(reservation.contact_email).to eq("test@example.com")
        expect(reservation.contact_phone).to eq("+56912345678")
      end
    end

    context "when seats are already held" do
      before do
        existing = create(:reservation, trip: trip)
        create(:reservation_seat, reservation: existing, seat_number: trip.bus.seats.first.seat_number, status: "held")
      end

      it "raises SeatUnavailableError" do
        seat_numbers = [trip.bus.seats.first.seat_number]

        expect {
          service.hold_seats(seat_numbers)
        }.to raise_error(SeatHoldService::SeatUnavailableError)
      end
    end

    context "when seats are confirmed" do
      before do
        existing = create(:reservation, :confirmed, trip: trip)
        create(:reservation_seat, :confirmed, reservation: existing, seat_number: trip.bus.seats.first.seat_number)
      end

      it "raises SeatUnavailableError" do
        seat_numbers = [trip.bus.seats.first.seat_number]

        expect {
          service.hold_seats(seat_numbers)
        }.to raise_error(SeatHoldService::SeatUnavailableError)
      end
    end

    context "with invalid seat numbers" do
      it "raises InvalidSeatError for non-existent seats" do
        expect {
          service.hold_seats(["INVALID-SEAT"])
        }.to raise_error(SeatHoldService::InvalidSeatError)
      end

      it "raises InvalidSeatError for empty array" do
        expect {
          service.hold_seats([])
        }.to raise_error(SeatHoldService::InvalidSeatError)
      end
    end

    context "concurrent access" do
      it "prevents double booking with pessimistic locking" do
        seat_number = trip.bus.seats.first.seat_number
        results = []
        errors = []

        threads = 2.times.map do
          Thread.new do
            begin
              reservation = described_class.new(trip).hold_seats([seat_number])
              results << reservation
            rescue SeatHoldService::SeatUnavailableError => e
              errors << e
            end
          end
        end

        threads.each(&:join)

        expect(results.count).to eq(1)
        expect(errors.count).to eq(1)
      end
    end
  end

  describe "#add_seats" do
    let(:reservation) { create(:reservation, trip: trip) }

    before do
      create(:reservation_seat, reservation: reservation, seat_number: trip.bus.seats.first.seat_number)
    end

    it "adds additional seats to existing reservation" do
      new_seat = trip.bus.seats.second.seat_number

      service.add_seats(reservation, [new_seat])

      expect(reservation.reservation_seats.count).to eq(2)
    end

    it "raises error if reservation is not held" do
      reservation.update!(status: "confirmed")
      new_seat = trip.bus.seats.second.seat_number

      expect {
        service.add_seats(reservation, [new_seat])
      }.to raise_error(RuntimeError, "Reservation is not held")
    end
  end

  describe "#remove_seats" do
    let(:reservation) { create(:reservation, trip: trip) }

    before do
      create(:reservation_seat, reservation: reservation, seat_number: trip.bus.seats.first.seat_number)
      create(:reservation_seat, reservation: reservation, seat_number: trip.bus.seats.second.seat_number)
    end

    it "removes specified seats from reservation" do
      seat_to_remove = trip.bus.seats.first.seat_number

      service.remove_seats(reservation, [seat_to_remove])

      expect(reservation.reservation_seats.count).to eq(1)
    end

    it "cancels reservation if all seats removed" do
      all_seats = reservation.reservation_seats.pluck(:seat_number)

      service.remove_seats(reservation, all_seats)

      expect(reservation.reload.status).to eq("cancelled")
    end
  end
end
