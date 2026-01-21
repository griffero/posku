# frozen_string_literal: true

class Passenger < ApplicationRecord
  belongs_to :reservation

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :document_type, presence: true, inclusion: { in: %w[rut passport dni] }
  validates :document_number, presence: true
  validates :seat_number, presence: true

  DOCUMENT_TYPES = {
    "rut" => "RUT",
    "passport" => "Pasaporte",
    "dni" => "DNI"
  }.freeze

  def document_type_label
    DOCUMENT_TYPES[document_type] || document_type
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
