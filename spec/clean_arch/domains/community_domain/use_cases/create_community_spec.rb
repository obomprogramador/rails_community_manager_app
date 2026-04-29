require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityDomain::UseCases::CreateCommunity do
  let(:community_repository) { instance_double('CommunityRepository') }
  let(:use_case)             { described_class.new(community_repository: community_repository) }
  let(:input_dto) do
    CleanArch::Domains::CommunityDomain::Dtos::CreateCommunityInputDto.new(
      name:        'Rails Brasil',
      description: 'Comunidade Rails'
    )
  end
  let(:community_entity) do
    CleanArch::Domains::CommunityDomain::Entities::CommunityEntity.new(
      id:          1,
      name:        'Rails Brasil',
      description: 'Comunidade Rails'
    )
  end

  describe '#call' do
    context 'quando nome disponível' do
      before do
        allow(community_repository).to receive(:exists_by_name?).and_return(false)
        allow(community_repository).to receive(:create).and_return(community_entity)
      end

      it 'retorna um CommunityOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::CommunityDomain::Dtos::CommunityOutputDto)
      end

      it 'retorna o nome correto' do
        output = use_case.call(input_dto)
        expect(output.name).to eq('Rails Brasil')
      end

      it 'retorna a descrição correta' do
        output = use_case.call(input_dto)
        expect(output.description).to eq('Comunidade Rails')
      end
    end

    context 'quando nome já em uso' do
      before do
        allow(community_repository).to receive(:exists_by_name?).and_return(true)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /em uso/)
      end
    end

    context 'quando nome inválido' do
      it 'levanta ArgumentError se muito curto' do
        input = CleanArch::Domains::CommunityDomain::Dtos::CreateCommunityInputDto.new(name: 'ab')
        allow(community_repository).to receive(:exists_by_name?).and_return(false)
        expect { use_case.call(input) }.to raise_error(CleanArch::Domains::DomainError, /curto/)
      end
    end
  end
end