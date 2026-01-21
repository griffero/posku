# frozen_string_literal: true

class Seat < ApplicationRecord
  belongs_to :bus

  validates :seat_number, presence: true, uniqueness: { scope: :bus_id }
  validates :seat_class, presence: true, inclusion: { in: %w[classic semi_cama salon_cama premium] }
  validates :floor, presence: true, inclusion: { in: [1, 2] }
  validates :row_number, presence: true, numericality: { greater_than: 0 }
  validates :column_number, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Seat classes with Spanish labels
  SEAT_CLASSES = {
    "classic" => "Clásico",
    "semi_cama" => "Semi Cama",
    "salon_cama" => "Salón Cama",
    "premium" => "Premium"
  }.freeze

  def seat_class_label
    SEAT_CLASSES[seat_class] || seat_class
  end
end
