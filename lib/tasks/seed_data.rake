namespace :seed_data do
  desc "TODO"
  task add_rental: :environment do
  	puts 'seeding data'
    puts 'creating rentals'
  	(1..10).each do |r|
  		rental = Rental.new(name: "Rental_#{r}", daily_rates: 10*r)
      if rental.save 
        puts "created rental #{rental.name}"
        puts "creating bookings for #{rental.name}"
        (1..5).each do |b|
          booking = rental.bookings.new(client_email: "text_user_#{b}@mail.com",
                                        start_at: Time.now + b.day,
                                        end_at:Time.now + (b+1).day,
                                        price: rental.daily_rates*1
                                        )
          if booking.save
            puts 'booking is created'
          end 
        end
      end
  	end
    puts 'data seeded'
  end
end
