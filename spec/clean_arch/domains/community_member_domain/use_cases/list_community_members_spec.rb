require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityMemberDomain::UseCases::ListCommunityMembers do
  let(:repository) { instance_double('CommunityMemberRepository') }
  let(:use_case)   { described_class.new(community_member_repository: repository) }
  let(:entities) do
    [
      CleanArch::Domains::CommunityMemberDomain::Entities::CommunityMemberEntity.new(
        id: 1, community_id: 1, user_id: 1, role: 'admin'
      ),
      CleanArch::Domains::CommunityMemberDomain::Entities::CommunityMemberEntity.new(
        id: 2, community_id: 1, user_id: 2, role: 'member'
      )
    ]
  end

  describe '#call' do
    context 'quando há membros na comunidade' do
      before do
        allow(repository).to receive(:list_by_community).and_return(entities)
      end

      it 'retorna lista de CommunityMemberOutputDto' do
        output = use_case.call(community_id: 1)
        expect(output).to all(be_a(CleanArch::Domains::CommunityMemberDomain::Dtos::CommunityMemberOutputDto))
      end

      it 'retorna a quantidade correta de membros' do
        output = use_case.call(community_id: 1)
        expect(output.size).to eq(2)
      end
    end

    context 'quando não há membros' do
      before do
        allow(repository).to receive(:list_by_community).and_return([])
      end

      it 'retorna lista vazia' do
        output = use_case.call(community_id: 1)
        expect(output).to be_empty
      end
    end

    context 'quando community_id é inválido' do
      it 'levanta DomainError' do
        expect { use_case.call(community_id: nil) }.to raise_error(CleanArch::Domains::DomainError, /obrigatório/)
      end
    end
  end
end