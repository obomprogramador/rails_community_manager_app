require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'POST /users' do
    context 'quando dados válidos' do
      it 'cria o usuário e retorna 201' do
        post '/users', params: { username: 'john_doe' }, as: :json

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body['username']).to eq('john_doe')
        expect(body['id']).to be_present
        expect(body['active']).to be true
      end
    end

    context 'quando username já existe' do
      before { create(:user, :with_username) }

      it 'retorna 422' do
        post '/users', params: { username: 'john_doe' }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['error']).to match(/em uso/i)
      end
    end

    context 'quando username inválido' do
      it 'retorna 422' do
        post '/users', params: { username: 'ab' }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['error']).to match(/curto/i)
      end
    end
  end

  describe 'DELETE /users/:id' do
    let!(:user) { create(:user) }

    context 'quando usuário existe' do
      it 'desativa e retorna 200' do
        delete "/users/#{user.id}", as: :json

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['active']).to be false
        expect(body['id']).to eq(user.id)
      end
    end

    context 'quando usuário não existe' do
      it 'retorna 422' do
        delete '/users/99999', as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['error']).to match(/não encontrado/i)
      end
    end
  end
end


# RSpec.describe 'Users API', type: :request do
#   describe 'POST /users' do
#     context 'quando acessado como JSON (bloqueado)' do
#       it 'retorna 403 forbidden' do
#         post '/users', params: { username: 'john_doe' }, as: :json
#         expect(response).to have_http_status(:forbidden)
#       end
#     end

#     context 'quando acessado como HTML (permitido)' do
#       it 'cria usuário e redireciona' do
#         post '/users', params: { username: 'john_doe' }
#         expect(response).to have_http_status(:forbidden), as: :json
#       end
#     end
#   end

#   describe 'DELETE /users/:id' do
#     let!(:user) { create(:user) }
#     it 'retorna 403 forbidden' do
#       delete "/users/#{user.id}", as: :json
#       expect(response).to have_http_status(:forbidden)
#     end
#   end
# end