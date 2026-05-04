require 'rails_helper'

RSpec.describe 'Communities API', type: :request do
  describe 'GET /communities' do
    before { create_list(:community, 3) }

    it 'retorna todas as comunidades com status 200' do
      get '/communities', as: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'POST /communities' do
    let(:creator) { create(:user) }

    context 'quando dados válidos' do
      before { sign_in(creator) }

      it 'cria a comunidade e retorna 201' do
        post '/communities',
             params: { name: 'Rails Brasil', description: 'Comunidade Rails' },
             as: :json
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body['name']).to eq('Rails Brasil')
        expect(body['creator_id']).to eq(creator.id)
      end
    end

    context 'quando não autenticado' do
      it 'retorna 422' do
        post '/communities', params: { name: 'Rails Brasil', description: 'Comunidade Rails' }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/autenticado/)
      end
    end

    context 'quando nome já existe' do
      before { create(:community, name: 'Rails Brasil') }

      before { sign_in(creator) }

      it 'retorna 422' do
        post '/communities',
             params: { name: 'Rails Brasil' },
             as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/em uso/)
      end
    end

    context 'quando nome inválido' do
      before { sign_in(creator) }
      it 'retorna 422' do
        post '/communities',
             params: { name: 'ab' },
             as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /communities/:id' do
    let!(:community) { create(:community, name: 'Rails Brasil') }

    context 'quando dados válidos' do
      it 'atualiza e retorna 200' do
        patch "/communities/#{community.id}", params: { name: 'Ruby Brasil' }, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Ruby Brasil')
      end
    end

    context 'quando comunidade não existe' do
      it 'retorna 422' do
        patch '/communities/99999', params: { name: 'Ruby Brasil' }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/não encontrada/)
      end
    end
  end

  describe 'GET /communities/search' do
    before { create(:community, name: 'Rails Brasil') }

    context 'quando encontra resultados' do
      it 'retorna comunidades e status 200' do
        get '/communities/search', params: { query: 'Rails' }, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).first['name']).to eq('Rails Brasil')
      end
    end

    context 'quando não encontra resultados' do
      it 'retorna 404' do
        get '/communities/search', params: { query: 'inexistente' }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end