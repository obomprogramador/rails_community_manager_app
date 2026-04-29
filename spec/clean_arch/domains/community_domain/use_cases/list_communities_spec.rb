require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityDomain::UseCases::ListCommunities do
  let(:community_repository) { instance_double('CommunityRepository') }
  let(:use_case)             { described_class.new(community_repository: community_repository) }
  let(:entities) do
    [
      CleanArch::Domains::CommunityDomain::Entities::CommunityEntity.new(id: 1, name: 'Rails Brasil'),
      CleanArch::Domains::CommunityDomain::Entities::CommunityEntity.new(id: 2, name: 'Ruby Brasil')
    ]
  end

  describe '#call' do
    before do
      allow(community_repository).to receive(:all).and_return(entities)
    end

    it 'retorna uma lista de CommunityOutputDto' do
      output = use_case.call
      expect(output).to all(be_a(CleanArch::Domains::CommunityDomain::Dtos::CommunityOutputDto))
    end

    it 'retorna a quantidade correta de comunidades' do
      output = use_case.call
      expect(output.size).to eq(2)
    end

    context 'quando não há comunidades' do
      before do
        allow(community_repository).to receive(:all).and_return([])
      end

      it 'retorna lista vazia' do
        output = use_case.call
        expect(output).to be_empty
      end
    end
  end
end