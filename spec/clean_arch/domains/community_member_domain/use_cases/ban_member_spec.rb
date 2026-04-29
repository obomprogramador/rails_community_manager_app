require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityMemberDomain::UseCases::BanMember do
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
    context 'quando membro existe e não está banido' do
      before do
        allow(repository).to receive(:find).and_return(entity)
        allow(repository).to receive(:save).and_return(entity)
      end

      it 'retorna um CommunityMemberOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::CommunityMemberDomain::Dtos::CommunityMemberOutputDto)
      end

      it 'bane o membro' do
        use_case.call(input_dto)
        expect(entity.banned?).to be true
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

    context 'quando membro já está banido' do
      before do
        entity.ban
        allow(repository).to receive(:find).and_return(entity)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /já está banido/)
      end
    end
  end
end