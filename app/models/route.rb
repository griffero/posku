# frozen_string_literal: true

class Route < ApplicationRecord
  belongs_to :origin_terminal, class_name: "Terminal"
  belongs_to :destination_terminal, class_name: "Terminal"

  has_many :trips, dependent: :restrict_with_error

  validates :distance_km, presence: true, numericality: { greater_than: 0 }
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :origin_terminal_id, uniqueness: { scope: :destination_terminal_id }
  validate :terminals_must_be_different

  scope :active, -> { where(active: true) }

  def display_name
    "#{origin_terminal.city} → #{destination_terminal.city}"
  end

  def duration_formatted
    hours = duration_minutes / 60
    mins = duration_minutes % 60
    hours > 0 ? "#{hours}h #{mins}m" : "#{mins}m"
  end

  private

  def terminals_must_be_different
    if origin_terminal_id == destination_terminal_id
      errors.add(:destination_terminal, "must be different from origin terminal")
    end
  end
end
