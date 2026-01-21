# frozen_string_literal: true

class Bus < ApplicationRecord
  has_many :seats, dependent: :destroy
  has_many :trips, dependent: :restrict_with_error

  validates :name, presence: true
  validates :bus_type, presence: true, inclusion: { in: %w[classic semi_cama salon_cama premium] }
  validates :plate_number, presence: true, uniqueness: true
  validates :total_seats, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  # Bus types with Spanish labels for UI
  BUS_TYPES = {
    "classic" => "Clásico",
    "semi_cama" => "Semi Cama",
    "salon_cama" => "Salón Cama",
    "premium" => "Premium"
  }.freeze

  def bus_type_label
    BUS_TYPES[bus_type] || bus_type
  end

  # Generate seats from layout JSON
  def generate_seats_from_layout!
    return unless seat_layout.present?

    transaction do
      seats.destroy_all

      seat_layout["floors"]&.each do |floor_data|
        floor = floor_data["floor"]
        floor_data["rows"]&.each_with_index do |row_data, row_idx|
          row_data["seats"]&.each_with_index do |seat_data, col_idx|
            next if seat_data.nil?

            seats.create!(
              seat_number: "#{floor}-#{row_data['row']}#{seat_data['col']}",
              seat_class: seat_data["class"],
              floor: floor,
              row_number: row_data["row"],
              column_number: col_idx
            )
          end
        end
      end

      update!(total_seats: seats.count)
    end
  end
end
