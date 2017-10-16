require 'rails_helper'

RSpec.describe 'Booking management', type: :request do
  describe 'Check CRUD token behaviour' do
    let(:rental) { create(:rental) }
    let(:params) { { booking: { client_email: "test_user@mail.com",
                                start_at: Time.now,
                                end_at: Time.now + 1.day,
                                price: 5, rental: rental.id 
                              } } }
    context 'when token is not present' do
      it 'responds with status false' do
        post '/bookings', params: params
        expect(JSON.parse(response.body)['status']).to eq(false)
      end
      
      let(:msg) { "Auth token can't be blank" }
      it 'responds with correct message' do
        post '/bookings', params: params
        expect(JSON.parse(response.body)['message']).to eq(msg)
      end   
    end
    
    context 'when token is invalid' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19ace0' } }
      it 'responds with status unauthorized' do
        post '/bookings', params: params.merge(auth_token)
        expect(JSON.parse(response.body)['status']).to eq('unauthorized')
      end

      let(:msg) { 'Incorrect token' }
      it 'responds with correct message' do
        post '/bookings', params: params.merge(auth_token)
        expect(JSON.parse(response.body)['message']).to eq(msg)
      end 
    end  
  end
  
  describe 'Create booking' do
    context 'when token is valid' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } }
      context 'with valid params' do
        let(:rental) { create(:rental) }
        let(:params) { { booking: { client_email: "test_user@mail.com",
                                    start_at: Time.now,
                                    end_at: Time.now + 1.day,
                                    price: 5, rental: rental.id 
                                  } } }

        it 'responds with success' do
          post '/bookings', params: params.merge(auth_token)
          expect(response.success?).to eq(true)
        end

        it 'responds with status 201' do
          post '/bookings', params: params.merge(auth_token)
          expect(response.status).to eq(201)
        end 

        it 'create new booking' do
          expect {
            post '/bookings', params: params.merge(auth_token)
         }.to change(Booking, :count).by(1)
        end                           
      end
      
      context 'with invalid params' do
        let!(:booking) { create(:booking) }

        context 'when client email is blank' do
          let(:params) { { booking: { client_email: '',
                                    start_at: Time.now,
                                    end_at: Time.now + 1.day,
                                    price: 5, rental: booking.rental.id 
                                  } } }
          it 'responds with success false' do
            post '/bookings', params: params.merge(auth_token)
            expect(response).to have_error(422)
          end

          it 'responds with correct validation message' do
            post '/bookings', params: params.merge(auth_token)
            error_msg = JSON.parse(response.body)['errors']['client_email'][0]
            expect(error_msg).to eq("can't be blank")
          end  
        end

        context 'when price is blank' do
          let(:params) { { booking: { client_email: 'test_user@mail.com',
                                      start_at: Time.now,
                                      end_at: Time.now + 1.day,
                                      rental: booking.rental.id 
                                    } } }
          it 'responds with success false' do
            post '/bookings', params: params.merge(auth_token)
            expect(response).to have_error(422)
          end

          it 'responds with correct validation message' do
            post '/bookings', params: params.merge(auth_token)
            error_msg = JSON.parse(response.body)['errors']['price'][0]
            expect(error_msg).to eq("can't be blank")
          end
        end

        context 'when price is not a number' do
          let(:params) { { booking: { client_email: 'test_user@mail.com',
                                    start_at: Time.now,
                                    end_at: Time.now + 1.day,
                                    price: 'price', rental: booking.rental.id 
                                  } } }
          it 'responds with success false' do
            post '/bookings', params: params.merge(auth_token)
            expect(response).to have_error(422)
          end

          it 'responds with correct validation message' do
            post '/bookings', params: params.merge(auth_token)
            error_msg = JSON.parse(response.body)['errors']['price'][0]
            expect(error_msg).to eq('is not a number')
          end  
        end 
      end  
    end  
  end

  describe 'Show booking' do 
    context 'with valid token' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } }
      let(:booking) { create(:booking) }

      it 'responds with success true' do
        get "/bookings/#{booking.id}", params: auth_token
        expect(response.success?).to eq(true)
      end

      it 'responds with status 200' do
        get "/bookings/#{booking.id}", params: auth_token
        expect(response.status).to eq(200)
      end

      it 'responds with requested rental' do
        get "/bookings/#{booking.id}", params: auth_token
        res_booking = JSON.parse(response.body)['booking']
        expect(res_booking['client_email']).to eq(booking.client_email)
        expect(res_booking['id']). to eq(booking.id)
        expect(res_booking['price']).to eq(booking.price)
      end
    end  
  end

  describe 'List of booking' do
    let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } }
    let(:rental) { create(:rental, name: 'Rental two')}
    let!(:booking1) { create(:booking, rental_id: rental.id) }
    let!(:booking2) { create(:booking, client_email: 'test_user@mail.com', start_at: Time.now + 4.day,
                              end_at: Time.now + 7.days, price: 15) }
    it 'responds with success true' do
      get '/bookings', params: auth_token
      expect(response.success?).to eq(true)
    end

    it 'responds with status 200' do
      get '/bookings', params: auth_token
      expect(response.status).to eq(200)
    end

    it 'responds with all bookings' do
      get '/bookings', params: auth_token
      expect(response.body).to eq({ bookings: Booking.all}.to_json)
    end  
  end

  describe 'Delete booking' do
    context 'with a valid token' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } } 
      let(:booking) { create(:booking) }
      it 'responds with status 204' do
        delete "/bookings/#{booking.id}", params: auth_token
        expect(response.status).to eq(204)
      end

      it 'responds with nil body' do
        delete "/bookings/#{booking.id}", params: auth_token
        expect(response.body).to eq('')
      end

      it 'deletes the rental' do
        delete "/bookings/#{booking.id}", params: auth_token
        booking_deleted = Booking.find_by(id: booking.id)
        expect(booking_deleted).to be_nil
      end
    end  
  end

  describe 'Update booking' do
    context 'with valid token' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } } 
      let(:booking) { create(:booking) }
      let(:params) { { booking: { client_email: "new_test_user@mail.com",
                                start_at: Time.now,
                                end_at: Time.now + 1.day,
                                price: 5, rental: booking.rental.id 
                              } } }
      it 'responds with success' do
        put "/bookings/#{booking.id}", params: params.merge(auth_token)
        expect(response.success?).to eq(true)
      end

      it 'responds with status 200' do
        put "/bookings/#{booking.id}", params: params.merge(auth_token)
        expect(response.status).to eq(200)
      end

      it 'responds with updated attributes' do
        put "/bookings/#{booking.id}", params: params.merge(auth_token)
        res_booking = JSON.parse(response.body)
        expect(res_booking['client_email']).to eq(params[:booking][:client_email])
      end
    end  
  end  
end	 