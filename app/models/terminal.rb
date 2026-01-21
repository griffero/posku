# frozen_string_literal: true

class Terminal < ApplicationRecord
  has_many :origin_routes, class_name: "Route", foreign_key: :origin_terminal_id, dependent: :restrict_with_error
  has_many :destination_routes, class_name: "Route", foreign_key: :destination_terminal_id, dependent: :restrict_with_error

  validates :name, presence: true
  validates :city, presence: true
  validates :code, presence: true, uniqueness: true, length: { is: 3 }

  scope :active, -> { where(active: true) }

  def display_name
    "#{name} (#{city})"
  end
end
