class Booking < ApplicationRecord
  # Valdation
  validates :start_at, :end_at, :client_email, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates_datetime :start_at, :end_at
  validates_datetime :end_at, after: :start_at
  validates_date :start_at, :end_at, on_or_after: lambda { Date.current }
  validate :book_time_overlap, if: Proc.new { |b| b.rental.present? }
  validate :minimum_booking_time
  validates :client_email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i


  # Association
  belongs_to :rental

  def as_json(options = {})
    data = super(options.merge(only: %i[id start_at end_at client_email price rental_id]))
    data = data.merge(rental_name: rental.name)
  end

  private
  def book_time_overlap
  	booking = rental.bookings.where(start_at: start_at..end_at, end_at: start_at..end_at)
    return unless booking.present?
    errors.add(:base, 'booking time is not available')
  end	

  def minimum_booking_time
    if end_at.present? && start_at.present?
      booking_time =  (end_at - start_at).to_i / 1.day
      return unless booking_time.zero?
      errors.add(:base, 'booking is only done for a day or night')
    end  
  end  
end
