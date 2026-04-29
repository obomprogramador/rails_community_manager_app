require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityMemberDomain::UseCases::DemoteMember do
  let(:repository) { instance_double('CommunityMemberRepository') }
  let(:use_case)   { described_class.new(community_member_repository: repository) }
  let(:input_dto) do
    CleanArch::Domains::CommunityMemberDomain::Dtos::MemberActionInputDto.new(
      community_id: 1,
      user_id:      1
    )
  end
  let(:admin_entity) do
    CleanArch::Domains::CommunityMemberDomain::Entities::CommunityMemberEntity.new(
      id: 1, community_id: 1, user_id: 1, role: 'admin'
    )
  end

  describe '#call' do
    context 'quando membro existe e pode ser rebaixado' do
      before do
        allow(repository).to receive(:find).and_return(admin_entity)
        allow(repository).to receive(:save).and_return(admin_entity)
      end

      it 'retorna um CommunityMemberOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::CommunityMemberDomain::Dtos::CommunityMemberOutputDto)
      end

      it 'rebaixa o membro' do
        use_case.call(input_dto)
        expect(admin_entity.role).to eq('moderator')
      end
    end

    context 'quando membro não encontrado' do
      before do
        allow(repository).to receive(:find).and_return(nil)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /não encontrado/)
      end
    end

    context 'quando membro é member e não pode ser rebaixado' do
      let(:member_entity) do
        CleanArch::Domains::CommunityMemberDomain::Entities::CommunityMemberEntity.new(
          id: 1, community_id: 1, user_id: 1, role: 'member'
        )
      end

      before do
        allow(repository).to receive(:find).and_return(member_entity)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /rebaixado/)
      end
    end
  end
end