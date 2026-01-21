# frozen_string_literal: true

class Trip < ApplicationRecord
  belongs_to :route
  belongs_to :bus

  has_many :fares, dependent: :destroy
  has_many :reservations, dependent: :restrict_with_error
  has_many :reservation_seats, through: :reservations

  has_one :origin_terminal, through: :route
  has_one :destination_terminal, through: :route

  validates :departure_at, presence: true
  validates :arrival_at, presence: true
  validates :status, presence: true, inclusion: { in: %w[scheduled boarding departed arrived cancelled] }
  validate :arrival_after_departure

  scope :scheduled, -> { where(status: "scheduled") }
  scope :upcoming, -> { where("departure_at > ?", Time.current) }
  scope :for_date, ->(date) { where(departure_at: date.beginning_of_day..date.end_of_day) }

  STATUSES = {
    "scheduled" => "Programado",
    "boarding" => "Abordando",
    "departed" => "En ruta",
    "arrived" => "Llegado",
    "cancelled" => "Cancelado"
  }.freeze

  def status_label
    STATUSES[status] || status
  end

  # Get occupied seat numbers for this trip
  def occupied_seat_numbers
    reservation_seats
      .joins(:reservation)
      .where(reservation_seats: { status: %w[held confirmed] })
      .where("reservations.hold_expires_at > ? OR reservations.status = ?", Time.current, "confirmed")
      .pluck(:seat_number)
  end

  # Get available seats count
  def available_seats_count
    bus.total_seats - occupied_seat_numbers.count
  end

  # Check if specific seats are available
  def seats_available?(seat_numbers)
    (seat_numbers & occupied_seat_numbers).empty?
  end

  # Get the base fare for a seat class
  def fare_for_seat_class(seat_class)
    fares.find_by(seat_class: seat_class) || fares.first
  end

  private

  def arrival_after_departure
    return unless departure_at && arrival_at

    if arrival_at <= departure_at
      errors.add(:arrival_at, "must be after departure time")
    end
  end
end
