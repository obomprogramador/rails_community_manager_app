require 'rails_helper'

RSpec.describe 'Messages API', type: :request do
  let!(:community) { create(:community) }
  let!(:user)      { create(:user) }
  let!(:message)   { create(:message, community: community, user: user) }

  describe 'GET /communities/:community_id/messages' do
    before { create_list(:message, 2, community: community, user: user) }

    it 'retorna todas as mensagens raiz com status 200' do
      get "/communities/#{community.id}/messages"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'POST /communities/:community_id/messages' do
    context 'quando dados válidos' do
      it 'cria a mensagem e retorna 201' do
        post "/communities/#{community.id}/messages",
          params: { user_id: user.id, content: 'Olá comunidade!' }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['content']).to eq('Olá comunidade!')
      end
    end

    context 'quando content é vazio' do
      it 'retorna 422' do
        post "/communities/#{community.id}/messages",
          params: { user_id: user.id, content: '' }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /communities/:community_id/messages/:id/reply' do
    context 'quando mensagem pai existe e é raiz' do
      it 'cria a resposta e retorna 201' do
        post "/communities/#{community.id}/messages/#{message.id}/reply",
          params: { user_id: user.id, content: 'Respondendo!' }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['parent_message_id']).to eq(message.id)
      end
    end

    context 'quando tenta responder uma resposta' do
      let!(:reply) { create(:message, community: community, user: user, parent_message_id: message.id) }

      it 'retorna 422' do
        post "/communities/#{community.id}/messages/#{reply.id}/reply",
          params: { user_id: user.id, content: 'Resposta da resposta' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/responder uma resposta/)
      end
    end
  end

  describe 'GET /communities/:community_id/messages/:id/replies' do
    before { create_list(:message, 2, community: community, user: user, parent_message_id: message.id) }

    it 'retorna mensagem pai e respostas em JSON com status 200' do
      get "/communities/#{community.id}/messages/#{message.id}/replies.json"
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['parent_message']['id']).to eq(message.id)
      expect(data['replies'].size).to eq(2)
    end
  end

  describe 'DELETE /communities/:community_id/messages/:id' do
    context 'quando usuário é o dono' do
      it 'deleta e retorna 200' do
        delete "/communities/#{community.id}/messages/#{message.id}",
          params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'quando usuário não é o dono' do
      let!(:other_user) { create(:user) }

      it 'retorna 422' do
        delete "/communities/#{community.id}/messages/#{message.id}",
          params: { user_id: other_user.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/permissão/)
      end
    end
  end

  describe 'PATCH /communities/:community_id/messages/:id/analyze_sentiment' do
    it 'retorna 422 pois AiRepository não está implementado' do
      patch "/communities/#{community.id}/messages/#{message.id}/analyze_sentiment"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end