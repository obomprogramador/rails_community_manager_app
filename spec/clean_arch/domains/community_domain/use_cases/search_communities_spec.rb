require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityDomain::UseCases::SearchCommunities do
  let(:community_repository) { instance_double('CommunityRepository') }
  let(:use_case)             { described_class.new(community_repository: community_repository) }
  let(:entities) do
    [
      CleanArch::Domains::CommunityDomain::Entities::CommunityEntity.new(id: 1, name: 'Rails Brasil')
    ]
  end

  describe '#call' do
    context 'quando encontra resultados' do
      before do
        allow(community_repository).to receive(:search).and_return(entities)
      end

      it 'retorna uma lista de CommunityOutputDto' do
        input = CleanArch::Domains::CommunityDomain::Dtos::SearchCommunityInputDto.new(query: 'Rails')
        output = use_case.call(input)
        expect(output).to all(be_a(CleanArch::Domains::CommunityDomain::Dtos::CommunityOutputDto))
      end

      it 'retorna o nome correto' do
        input = CleanArch::Domains::CommunityDomain::Dtos::SearchCommunityInputDto.new(query: 'Rails')
        output = use_case.call(input)
        expect(output.first.name).to eq('Rails Brasil')
      end
    end

    context 'quando não encontra resultados' do
      before do
        allow(community_repository).to receive(:search).and_return([])
      end

      it 'levanta DomainError' do
        input = CleanArch::Domains::CommunityDomain::Dtos::SearchCommunityInputDto.new(query: 'inexistente')
        expect { use_case.call(input) }.to raise_error(CleanArch::Domains::DomainError, /Nenhuma comunidade encontrada/)
      end
    end

    context 'quando query é vazia' do
      it 'levanta ArgumentError' do
        expect { CleanArch::Domains::CommunityDomain::Dtos::SearchCommunityInputDto.new(query: '') }
          .to raise_error(ArgumentError, /vazia/)
      end
    end
  end
end