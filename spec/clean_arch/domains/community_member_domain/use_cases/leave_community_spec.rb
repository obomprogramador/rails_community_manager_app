require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityMemberDomain::UseCases::LeaveCommunity do
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
        allow(repository).to receive(:delete).and_return(true)
      end

      it 'retorna true' do
        expect(use_case.call(input_dto)).to be true
      end
    end

    context 'quando membro não encontrado' do
      before do
        allow(repository).to receive(:find).and_return(nil)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /não é membro/)
      end
    end

    context 'quando membro está banido' do
      before do
        entity.ban
        allow(repository).to receive(:find).and_return(entity)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /banido/)
      end
    end
  end
end