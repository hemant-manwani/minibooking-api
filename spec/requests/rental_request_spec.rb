require 'rails_helper'

RSpec.describe 'Rental management', type: :request do
  describe 'CRUD token behaviour' do
    let(:params) { { rental: { name: "Rental one", daily_rates: 25 } } }
    context 'when token is no present' do
      it 'responds with status false' do
        post '/rentals', params: params
        expect(JSON.parse(response.body)['status']).to eq(false)
      end

      let(:msg) { "Auth token can't be blank" }
      it 'responds with correct message' do
        post '/rentals', params: params
        expect(JSON.parse(response.body)['message']).to eq(msg)
      end   
    end

    context 'when token is incorrect' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19ace0' } }
      it 'responds with status unauthorized' do
        post '/rentals', params: params.merge(auth_token)
        expect(JSON.parse(response.body)['status']).to eq('unauthorized')
      end

      let(:msg) { 'Incorrect token' }
      it 'responds with correct message' do
        post '/rentals', params: params.merge(auth_token)
        expect(JSON.parse(response.body)['message']).to eq(msg)
      end 
    end  
  end  

  describe 'Create a rental' do
    context 'with a valid token' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } } 

      context 'when params are not valid' do
        context 'when name is not present' do
          let(:params) { { rental: { name: "", daily_rates: 25 } } }
          it 'responds with success false' do 
            post '/rentals',  params: params.merge(auth_token)
            expect(response).to have_error(422)
          end

          let(:msg) { "can't be blank" }
          it 'responds with valid error message' do
            post '/rentals', params: params.merge(auth_token)
            error_msg = JSON.parse(response.body)['errors']['name']
            expect(error_msg).to eq([msg])
          end  
        end

        context 'when rental with the given name alredy present' do
          let!(:rental) { create(:rental) }
          let(:params) { { rental: { name: "Rental one", daily_rates: 25 } } }
          it 'responds with status 422' do
            post '/rentals', params: params.merge(auth_token)
            expect(response).to have_error(422)
          end

          let(:msg) { 'has already been taken'}
          it 'responds with correct error message' do
            post '/rentals', params: params.merge(auth_token)
            error_msg = JSON.parse(response.body)['errors']['name']
            expect(error_msg).to eq([msg])
          end  
        end

        context 'when daily rates is not present' do
          let(:params) { { rental: { name: "Rental one" } } }
          it 'responds with success false' do 
            post '/rentals',  params: params.merge(auth_token)
            expect(response).to have_error(422)
          end

          let(:msg) { "can't be blank" }
          it 'responds with valid error message' do
            post '/rentals', params: params.merge(auth_token)
            error_msg = JSON.parse(response.body)['errors']['daily_rates'][0]
            expect(error_msg).to eq(msg)
          end  
        end

        context 'when daily rates is not a number' do
          let(:params) { { rental: { name: "Rental one", daily_rates: 'rate' } } }
          it 'responds with success false' do 
            post '/rentals',  params: params.merge(auth_token)
            expect(response).to have_error(422)
          end

          let(:msg) { "is not a number" }
          it 'responds with valid error message' do
            post '/rentals', params: params.merge(auth_token)
            error_msg = JSON.parse(response.body)['errors']['daily_rates'][0]
            expect(error_msg).to eq(msg)
          end  
        end 
      end

      context 'when params are valid' do 
        let(:params) { { rental: { name: "Rental one", daily_rates: 25 } } }
        it 'responds with success true' do
          post '/rentals', params: params.merge(auth_token)
          expect(response.success?).to eq(true)
        end

        it 'responds with status 201' do
          post '/rentals', params: params.merge(auth_token)
          expect(response.status).to eq(201)
        end

        it 'create new rental' do
          expect {
            post '/rentals', params: params.merge(auth_token)
         }.to change(Rental, :count).by(1)
        end  
      end  
    end 
  end

  describe 'Show a rental' do
    let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } } 
    let(:rental) { create(:rental) }
    it 'responds with success true' do
      get "/rentals/#{rental.id}", params: auth_token
      expect(response.success?).to eq(true)
    end
    
    it 'responds with status 200' do
      get "/rentals/#{rental.id}", params: auth_token
      expect(response.status).to eq(200)
    end

    it 'responds with requested rental' do
      get "/rentals/#{rental.id}", params: auth_token
      res_rental = JSON.parse(response.body)['rental']
      expect(res_rental['name']).to eq(rental.name)
      expect(res_rental['id']). to eq(rental.id)
      expect(res_rental['daily_rates']).to eq(rental.daily_rates)
    end  
  end

  describe 'Listing rentals' do
    let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0', per_page: 1 } } 
    let!(:rental1) { create(:rental) }
    let!(:rental2) { create(:rental, name: 'Rental two') }
    it 'responds with success true' do
      get '/rentals', params: auth_token
      expect(response.success?).to eq(true)
    end

    it 'responds with status 200' do
      get '/rentals', params: auth_token
      expect(response.status).to eq(200)
    end 
  end

  describe 'delete a rental' do
    context 'with a valid token' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } } 
      let(:rental) { create(:rental) }
      it 'responds with status 204' do
        delete "/rentals/#{rental.id}", params: auth_token
        expect(response.status).to eq(204)
      end

      it 'responds with nil body' do
        delete "/rentals/#{rental.id}", params: auth_token
        expect(response.body).to eq('')
      end

      it 'deletes the rental' do
        delete "/rentals/#{rental.id}", params: auth_token
        rental_deleted = Rental.find_by(id: rental.id)
        expect(rental_deleted).to be_nil
      end
    end  
  end

  describe 'update a rental' do
    context 'with valid token' do
      let(:auth_token) { { auth_token: 'f790216ba928874ebe19a240d54ce0' } } 
      let(:rental) { create(:rental) }
      context 'with valid params' do
        let(:params)  { { rental: { name: "Rental Updated"} } }
        it 'responds with success' do
          put "/rentals/#{rental.id}", params: params.merge(auth_token)
          expect(response.success?).to eq(true)
        end

        it 'responds with status 200' do
          put "/rentals/#{rental.id}", params: params.merge(auth_token)
          expect(response.status).to eq(200)
        end

        it 'responds with updated attributes' do
          put "/rentals/#{rental.id}", params: params.merge(auth_token)
          res_rental = JSON.parse(response.body)['rental']
          expect(res_rental['name']).to eq(params[:rental][:name])
        end  
      end

      context 'with invalid params' do
        let(:params)  { { rental: { name: ''} } }
        it 'responds with success' do
          put "/rentals/#{rental.id}", params: params.merge(auth_token)
          expect(response.success?).to eq(false)
        end

        it 'responds with status 200' do
          put "/rentals/#{rental.id}", params: params.merge(auth_token)
          expect(response.status).to eq(422)
        end
        let(:msg) { "can't be blank" }
        it 'responds with valid error message' do
          put "/rentals/#{rental.id}", params: params.merge(auth_token)
          error_msg = JSON.parse(response.body)['errors']['name']
          expect(error_msg).to eq([msg])
        end  
      end  
    end
  end
end