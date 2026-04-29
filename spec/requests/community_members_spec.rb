require 'rails_helper'

RSpec.describe 'CommunityMembers API', type: :request do
  let!(:community) { create(:community) }
  let!(:user)      { create(:user) }

  describe 'GET /communities/:community_id/community_members' do
    before { create_list(:community_member, 3, community: community) }

    it 'retorna todos os membros com status 200' do
      get "/communities/#{community.id}/community_members"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'POST /communities/:community_id/community_members' do
    context 'quando usuário ainda não é membro' do
      it 'entra na comunidade e retorna 201' do
        post "/communities/#{community.id}/community_members",
          params: { user_id: user.id }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['role']).to eq('member')
      end
    end

    context 'quando usuário já é membro' do
      before { create(:community_member, community: community, user: user) }

      it 'retorna 422' do
        post "/communities/#{community.id}/community_members",
          params: { user_id: user.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/já é membro/)
      end
    end
  end

  describe 'DELETE /communities/:community_id/community_members/:id' do
    let!(:member) { create(:community_member, community: community, user: user) }

    context 'quando membro existe' do
      it 'sai da comunidade e retorna 200' do
        delete "/communities/#{community.id}/community_members/#{member.id}",
          params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH /communities/:community_id/community_members/:id/promote' do
    let!(:member) { create(:community_member, community: community, user: user, role: 'member') }

    it 'promove o membro e retorna 200' do
      patch "/communities/#{community.id}/community_members/#{member.id}/promote",
        params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['role']).to eq('moderator')
    end
  end

  describe 'PATCH /communities/:community_id/community_members/:id/demote' do
    let!(:member) { create(:community_member, community: community, user: user, role: 'admin') }

    it 'rebaixa o membro e retorna 200' do
      patch "/communities/#{community.id}/community_members/#{member.id}/demote",
        params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['role']).to eq('moderator')
    end
  end

  describe 'PATCH /communities/:community_id/community_members/:id/ban' do
    let!(:member) { create(:community_member, community: community, user: user) }

    context 'quando membro existe e não está banido' do
      it 'bane o membro e retorna 200' do
        patch "/communities/#{community.id}/community_members/#{member.id}/ban",
          params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['role']).to eq('banned')
      end
    end
  end
end