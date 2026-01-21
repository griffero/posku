# frozen_string_literal: true

class PricingService
  def initialize(trip)
    @trip = trip
  end

  # Get price for a specific seat
  def price_for_seat(seat_number, coupon_code: nil)
    seat = @trip.bus.seats.find_by(seat_number: seat_number)
    return nil unless seat

    fare = @trip.fare_for_seat_class(seat.seat_class)
    return nil unless fare

    base_price = fare.calculate_price(date: @trip.departure_at)

    # Apply coupon discount if provided
    if coupon_code.present?
      discount = calculate_coupon_discount(base_price, coupon_code)
      base_price -= discount
    end

    {
      seat_number: seat_number,
      seat_class: seat.seat_class,
      price_cents: base_price,
      currency: fare.currency
    }
  end

  # Get prices for multiple seats
  def prices_for_seats(seat_numbers, coupon_code: nil)
    seat_numbers.map { |sn| price_for_seat(sn, coupon_code: coupon_code) }.compact
  end

  # Calculate total for a set of seats
  def calculate_total(seat_numbers, coupon_code: nil)
    prices = prices_for_seats(seat_numbers, coupon_code: coupon_code)
    {
      seats: prices,
      subtotal_cents: prices.sum { |p| p[:price_cents] },
      discount_cents: 0,
      total_cents: prices.sum { |p| p[:price_cents] },
      currency: "CLP"
    }
  end

  private

  # Simple coupon discount calculation (mock)
  def calculate_coupon_discount(price, coupon_code)
    case coupon_code.upcase
    when "DESCUENTO10"
      (price * 0.10).round
    when "DESCUENTO20"
      (price * 0.20).round
    when "VERANO2026"
      (price * 0.15).round
    else
      0
    end
  end
end
