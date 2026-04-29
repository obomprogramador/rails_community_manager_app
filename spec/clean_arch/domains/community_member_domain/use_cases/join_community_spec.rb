require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityMemberDomain::UseCases::JoinCommunity do
  let(:repository) { instance_double('CommunityMemberRepository') }
  let(:use_case)   { described_class.new(community_member_repository: repository) }
  let(:input_dto) do
    CleanArch::Domains::CommunityMemberDomain::Dtos::JoinCommunityInputDto.new(
      community_id: 1,
      user_id:      1
    )
  end
  let(:entity) do
    CleanArch::Domains::CommunityMemberDomain::Entities::CommunityMemberEntity.new(
      id: 1, community_id: 1, user_id: 1, role: 'member'
    )
  end

  describe '#call' do
    context 'quando usuário ainda não é membro' do
      before do
        allow(repository).to receive(:exists?).and_return(false)
        allow(repository).to receive(:create).and_return(entity)
      end

      it 'retorna um CommunityMemberOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::CommunityMemberDomain::Dtos::CommunityMemberOutputDto)
      end

      it 'retorna role member por padrão' do
        output = use_case.call(input_dto)
        expect(output.role).to eq('member')
      end
    end

    context 'quando usuário já é membro' do
      before do
        allow(repository).to receive(:exists?).and_return(true)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /já é membro/)
      end
    end
  end
end