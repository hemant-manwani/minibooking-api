require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe "validations" do
    it { should validate_presence_of(:client_email) }
    it { should validate_presence_of(:start_at) }
    it { should validate_presence_of(:rental) }
    it { should validate_presence_of(:end_at) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price) }
    
    let!(:booking) { create(:booking) }
    it "is not valid when book time overlap" do 
      expect(Booking.new(start_at: booking.start_at,
                         end_at: booking.end_at,
                         client_email: 'test_user@mail.com', 
                         price: 50,
                         rental_id: booking.rental_id)).not_to be_valid
    end

    it 'is not valid when book time is less than minimum' do
      expect(Booking.new(start_at: Time.now,
                         end_at: Time.now + 3.hours,
                         client_email: 'test_user@mail.com', 
                         price: 50,
                         rental_id: booking.rental_id)).not_to be_valid
    end

    it 'is not valid when start time after the end time' do
      expect(Booking.new(start_at: Time.now + 5.day,
                         end_at: booking.end_at + 1.day,
                         client_email: 'test_user@mail.com', 
                         price: 50,
                         rental_id: booking.rental_id)).not_to be_valid
    end

    it 'is not valid when start time and end time before current time' do
      expect(Booking.new(start_at: Time.now - 2.day,
                         end_at: booking.end_at - 1.day,
                         client_email: 'test_user@mail.com', 
                         price: 50,
                         rental_id: booking.rental_id)).not_to be_valid
    end  
  end

  describe 'Associations' do
    it { should belong_to(:rental) }
  end  
end