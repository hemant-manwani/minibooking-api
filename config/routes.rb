Rails.application.routes.draw do
  resources :rentals
  resources :bookings do
    collection do
      get ':rental_id/get_price', to: 'bookings#get_price'
    end
  end
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
