class Rental < ApplicationRecord
  # Validations
  validates :name, :daily_rates, presence: true
  validates :daily_rates, numericality: { greater_than: 0 }
  validates :name, uniqueness: true
  
  # Associations
  has_many :bookings, dependent: :destroy

  def calculate_price(start_at, end_at)
    # Assuming hotel work on 12pm to 12pm shift
    (start_at.to_date - end_at.to_date).to_i * daily_rates
  end
end
