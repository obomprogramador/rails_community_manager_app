require 'rails_helper'

RSpec.describe 'Reactions API', type: :request do
  let!(:community) { create(:community) }
  let!(:user)      { create(:user) }
  let!(:message)   { create(:message, community: community, user: user) }

  describe 'GET /communities/:community_id/messages/:message_id/reactions' do
    before do
      create(:reaction, message: message, user: user, reaction_type: 'like')
      create(:reaction, message: message, user: create(:user), reaction_type: 'love')
    end

    it 'retorna todas as reações com status 200' do
      get "/communities/#{community.id}/messages/#{message.id}/reactions"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe 'POST /communities/:community_id/messages/:message_id/reactions' do
    context 'quando reação ainda não existe' do
      it 'cria a reação e retorna 201' do
        post "/communities/#{community.id}/messages/#{message.id}/reactions",
          params: { user_id: user.id, reaction_type: 'like' }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['reaction_type']).to eq('like')
      end
    end

    context 'quando reação já existe' do
      before do
        create(:reaction, message: message, user: user, reaction_type: 'like')
      end

      it 'retorna 422' do
        post "/communities/#{community.id}/messages/#{message.id}/reactions",
          params: { user_id: user.id, reaction_type: 'like' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/já reagiu/)
      end
    end

    context 'quando reaction_type é inválido' do
      it 'retorna 422' do
        post "/communities/#{community.id}/messages/#{message.id}/reactions",
          params: { user_id: user.id, reaction_type: 'dislike' }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /communities/:community_id/messages/:message_id/reactions/:id' do
    let!(:reaction) { create(:reaction, message: message, user: user, reaction_type: 'like') }

    context 'quando reação existe' do
      it 'remove a reação e retorna 200' do
        delete "/communities/#{community.id}/messages/#{message.id}/reactions/#{reaction.id}",
          params: { user_id: user.id, reaction_type: 'like' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to match(/removida/)
      end
    end

    context 'quando reação não existe' do
      it 'retorna 422' do
        delete "/communities/#{community.id}/messages/#{message.id}/reactions/#{reaction.id}",
          params: { user_id: user.id, reaction_type: 'love' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/não encontrada/)
      end
    end
  end
end