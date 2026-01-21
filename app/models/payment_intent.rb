# frozen_string_literal: true

class PaymentIntent < ApplicationRecord
  belongs_to :reservation

  validates :provider, presence: true, inclusion: { in: %w[fintoc_mock] }
  validates :status, presence: true, inclusion: { in: %w[created pending succeeded failed expired] }
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[CLP USD] }

  before_create :generate_external_id
  before_create :set_expiration

  scope :pending, -> { where(status: %w[created pending]) }
  scope :succeeded, -> { where(status: "succeeded") }

  STATUSES = {
    "created" => "Creado",
    "pending" => "Pendiente",
    "succeeded" => "Exitoso",
    "failed" => "Fallido",
    "expired" => "Expirado"
  }.freeze

  EXPIRATION_TIME = 15.minutes

  def status_label
    STATUSES[status] || status
  end

  def mark_as_pending!
    update!(status: "pending")
  end

  def mark_as_succeeded!
    transaction do
      update!(status: "succeeded")
      reservation.confirm!
    end
  end

  def mark_as_failed!
    update!(status: "failed")
  end

  def mark_as_expired!
    update!(status: "expired")
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def amount
    amount_cents / 100.0
  end

  def formatted_amount
    if currency == "CLP"
      "$#{amount_cents.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}"
    else
      "$#{format('%.2f', amount)} #{currency}"
    end
  end

  # Mock payment URL (simulates Fintoc widget URL)
  def payment_url
    "/payment/#{external_id}"
  end

  private

  def generate_external_id
    return if external_id.present?

    self.external_id = "pi_#{SecureRandom.hex(12)}"
  end

  def set_expiration
    self.expires_at ||= EXPIRATION_TIME.from_now
  end
end
