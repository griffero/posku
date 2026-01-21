# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :trip

  has_many :passengers, dependent: :destroy
  has_many :reservation_seats, dependent: :destroy
  has_many :payment_intents, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[pending held confirmed cancelled expired] }
  validates :locator_code, uniqueness: true, allow_nil: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :currency, presence: true, inclusion: { in: %w[CLP USD] }

  before_create :generate_locator_code

  scope :active, -> { where(status: %w[pending held confirmed]) }
  scope :held, -> { where(status: "held") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :expired_holds, -> { held.where("hold_expires_at < ?", Time.current) }

  STATUSES = {
    "pending" => "Pendiente",
    "held" => "Reservado",
    "confirmed" => "Confirmado",
    "cancelled" => "Cancelado",
    "expired" => "Expirado"
  }.freeze

  HOLD_DURATION = 8.minutes

  def status_label
    STATUSES[status] || status
  end

  def hold_active?
    status == "held" && hold_expires_at.present? && hold_expires_at > Time.current
  end

  def hold_time_remaining
    return 0 unless hold_active?
    (hold_expires_at - Time.current).to_i
  end

  def expire_hold!
    return unless status == "held"

    transaction do
      update!(status: "expired")
      reservation_seats.update_all(status: "released")
    end
  end

  def confirm!
    return unless status == "held"

    transaction do
      update!(status: "confirmed", hold_expires_at: nil)
      reservation_seats.update_all(status: "confirmed")
    end
  end

  def cancel!
    return if status == "confirmed" # Confirmed reservations need special handling

    transaction do
      update!(status: "cancelled")
      reservation_seats.update_all(status: "released")
    end
  end

  def total_amount
    total_amount_cents / 100.0
  end

  def formatted_total
    if currency == "CLP"
      "$#{total_amount_cents.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}"
    else
      "$#{format('%.2f', total_amount)} #{currency}"
    end
  end

  def recalculate_total!
    total = reservation_seats.sum(:price_cents)
    update!(total_amount_cents: total)
  end

  private

  def generate_locator_code
    return if locator_code.present?

    loop do
      self.locator_code = SecureRandom.alphanumeric(6).upcase
      break unless Reservation.exists?(locator_code: locator_code)
    end
  end
end
