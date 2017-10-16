require 'rails_helper'

RSpec.describe Rental, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:daily_rates) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_numericality_of(:daily_rates) }
    
    it "is not valid with null attributes" do 
      expect(Rental.new).not_to be_valid
    end 

    it 'is valid with valid attributes' do
      expect(Rental.new(name: 'Rental one', daily_rates: 5)).to be_valid
    end  

    it "is not valid without a name" do
      expect(Rental.new(daily_rates: 5)).not_to be_valid
    end

    it "is not valid without a description" do
      expect(Rental.new(name: 'Rental one')).not_to be_valid
    end  

    it "is not valid when daily rates not number" do
      expect(Rental.new(name: 'Rental one', daily_rates: "rate")).not_to be_valid
    end  

    it "is not valid when name is already taken" do
      create(:rental)
      expect(Rental.new(name: 'Rental one', daily_rates: 25)).not_to be_valid
    end  
  end

  describe 'Associations' do
    it { should have_many(:bookings).dependent(:destroy) }
  end  
end
