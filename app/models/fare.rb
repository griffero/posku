# frozen_string_literal: true

class Fare < ApplicationRecord
  belongs_to :trip

  validates :seat_class, presence: true
  validates :currency, presence: true, inclusion: { in: %w[CLP USD] }
  validates :base_price_cents, presence: true, numericality: { greater_than: 0 }

  # Calculate final price applying pricing rules
  def calculate_price(options = {})
    price = base_price_cents

    return price unless pricing_rules.present?

    # Apply day of week multiplier
    if pricing_rules["day_multipliers"].present?
      day_name = options[:date]&.strftime("%A")&.downcase || Time.current.strftime("%A").downcase
      multiplier = pricing_rules["day_multipliers"][day_name] || 1.0
      price = (price * multiplier).round
    end

    # Apply time of day multiplier
    if pricing_rules["time_multipliers"].present?
      hour = options[:hour] || Time.current.hour
      time_slot = case hour
                  when 6..11 then "morning"
                  when 12..17 then "afternoon"
                  when 18..23 then "evening"
                  else "night"
                  end
      multiplier = pricing_rules["time_multipliers"][time_slot] || 1.0
      price = (price * multiplier).round
    end

    price
  end

  def base_price
    base_price_cents / 100.0
  end

  def formatted_price
    if currency == "CLP"
      "$#{base_price_cents.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}"
    else
      "$#{format('%.2f', base_price)} #{currency}"
    end
  end
end
