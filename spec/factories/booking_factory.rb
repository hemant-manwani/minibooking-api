FactoryGirl.define do
  factory :booking do
    client_email 'test_user@mail.com'
    start_at Time.now + 1.day
    end_at Time.now + 2.day
    price 50
    rental
  end
end






