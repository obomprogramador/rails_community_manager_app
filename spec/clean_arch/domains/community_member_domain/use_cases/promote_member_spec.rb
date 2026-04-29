require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityMemberDomain::UseCases::PromoteMember do
  let(:repository) { instance_double('CommunityMemberRepository') }
  let(:use_case)   { described_class.new(community_member_repository: repository) }
  let(:input_dto) do
    CleanArch::Domains::CommunityMemberDomain::Dtos::MemberActionInputDto.new(
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
    context 'quando membro existe e pode ser promovido' do
      before do
        allow(repository).to receive(:find).and_return(entity)
        allow(repository).to receive(:save).and_return(entity)
      end

      it 'retorna um CommunityMemberOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::CommunityMemberDomain::Dtos::CommunityMemberOutputDto)
      end

      it 'promove o membro' do
        use_case.call(input_dto)
        expect(entity.role).to eq('moderator')
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

    context 'quando membro é admin e não pode ser promovido' do
      let(:admin_entity) do
        CleanArch::Domains::CommunityMemberDomain::Entities::CommunityMemberEntity.new(
          id: 1, community_id: 1, user_id: 1, role: 'admin'
        )
      end

      before do
        allow(repository).to receive(:find).and_return(admin_entity)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /promovido/)
      end
    end
  end
end