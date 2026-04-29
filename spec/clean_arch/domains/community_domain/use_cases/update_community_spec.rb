require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityDomain::UseCases::UpdateCommunity do
  let(:community_repository) { instance_double('CommunityRepository') }
  let(:use_case)             { described_class.new(community_repository: community_repository) }
  let(:community_entity) do
    CleanArch::Domains::CommunityDomain::Entities::CommunityEntity.new(
      id:          1,
      name:        'Rails Brasil',
      description: 'Comunidade Rails'
    )
  end

  describe '#call' do
    context 'quando comunidade existe' do
      before do
        allow(community_repository).to receive(:find).and_return(community_entity)
        allow(community_repository).to receive(:exists_by_name?).and_return(false)
        allow(community_repository).to receive(:save).and_return(community_entity)
      end

      it 'atualiza o nome' do
        input = CleanArch::Domains::CommunityDomain::Dtos::UpdateCommunityInputDto.new(
          id:   1,
          name: 'Ruby Brasil'
        )
        output = use_case.call(input)
        expect(output).to be_a(CleanArch::Domains::CommunityDomain::Dtos::CommunityOutputDto)
      end

      it 'atualiza a descrição' do
        input = CleanArch::Domains::CommunityDomain::Dtos::UpdateCommunityInputDto.new(
          id:          1,
          description: 'Nova descrição'
        )
        output = use_case.call(input)
        expect(output).to be_a(CleanArch::Domains::CommunityDomain::Dtos::CommunityOutputDto)
      end
    end

    context 'quando comunidade não encontrada' do
      before do
        allow(community_repository).to receive(:find).and_return(nil)
      end

      it 'levanta DomainError' do
        input = CleanArch::Domains::CommunityDomain::Dtos::UpdateCommunityInputDto.new(
          id:   99,
          name: 'Ruby Brasil'
        )
        expect { use_case.call(input) }.to raise_error(CleanArch::Domains::DomainError, /não encontrada/)
      end
    end

    context 'quando novo nome já em uso' do
      before do
        allow(community_repository).to receive(:find).and_return(community_entity)
        allow(community_repository).to receive(:exists_by_name?).and_return(true)
      end

      it 'levanta DomainError' do
        input = CleanArch::Domains::CommunityDomain::Dtos::UpdateCommunityInputDto.new(
          id:   1,
          name: 'Rails Brasil'
        )
        expect { use_case.call(input) }.to raise_error(CleanArch::Domains::DomainError, /em uso/)
      end
    end
  end
end