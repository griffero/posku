# frozen_string_literal: true

class ReservationSeat < ApplicationRecord
  belongs_to :reservation

  validates :seat_number, presence: true
  validates :seat_class, presence: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[held confirmed released] }
  validates :seat_number, uniqueness: { scope: :reservation_id }

  STATUSES = {
    "held" => "Reservado",
    "confirmed" => "Confirmado",
    "released" => "Liberado"
  }.freeze

  def status_label
    STATUSES[status] || status
  end

  def price
    price_cents / 100.0
  end

  def formatted_price
    currency = reservation.currency
    if currency == "CLP"
      "$#{price_cents.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}"
    else
      "$#{format('%.2f', price)} #{currency}"
    end
  end
end
