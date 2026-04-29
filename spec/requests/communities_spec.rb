require 'rails_helper'

RSpec.describe 'Communities API', type: :request do
  describe 'GET /communities' do
    before { create_list(:community, 3) }

    it 'retorna todas as comunidades com status 200' do
      get '/communities'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'POST /communities' do
    context 'quando dados válidos' do
      it 'cria a comunidade e retorna 201' do
        post '/communities', params: { name: 'Rails Brasil', description: 'Comunidade Rails' }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('Rails Brasil')
      end
    end

    context 'quando nome já existe' do
      before { create(:community, name: 'Rails Brasil') }

      it 'retorna 422' do
        post '/communities', params: { name: 'Rails Brasil' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/em uso/)
      end
    end

    context 'quando nome inválido' do
      it 'retorna 422' do
        post '/communities', params: { name: 'ab' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /communities/:id' do
    let!(:community) { create(:community, name: 'Rails Brasil') }

    context 'quando dados válidos' do
      it 'atualiza e retorna 200' do
        patch "/communities/#{community.id}", params: { name: 'Ruby Brasil' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Ruby Brasil')
      end
    end

    context 'quando comunidade não existe' do
      it 'retorna 422' do
        patch '/communities/99999', params: { name: 'Ruby Brasil' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/não encontrada/)
      end
    end
  end

  describe 'GET /communities/search' do
    before { create(:community, name: 'Rails Brasil') }

    context 'quando encontra resultados' do
      it 'retorna comunidades e status 200' do
        get '/communities/search', params: { query: 'Rails' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).first['name']).to eq('Rails Brasil')
      end
    end

    context 'quando não encontra resultados' do
      it 'retorna 404' do
        get '/communities/search', params: { query: 'inexistente' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end