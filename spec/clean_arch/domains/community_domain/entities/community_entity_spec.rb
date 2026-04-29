require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityDomain::Entities::CommunityEntity do
  let(:community_entity) do
    described_class.new(id: 1, name: 'Rails Brasil', description: 'Comunidade Rails')
  end

  describe '#initialize' do
    it 'cria com nome e descrição' do
      expect(community_entity.name).to eq('Rails Brasil')
      expect(community_entity.description).to eq('Comunidade Rails')
    end

    it 'aceita descrição nil' do
      entity = described_class.new(id: 1, name: 'Rails Brasil')
      expect(entity.description).to eq('')
    end
  end

  describe '#update_info' do
    it 'atualiza o nome' do
      community_entity.update_info(name: 'Ruby Brasil')
      expect(community_entity.name).to eq('Ruby Brasil')
    end

    it 'atualiza a descrição' do
      community_entity.update_info(description: 'Nova descrição')
      expect(community_entity.description).to eq('Nova descrição')
    end

    it 'atualiza nome e descrição juntos' do
      community_entity.update_info(name: 'Ruby Brasil', description: 'Nova descrição')
      expect(community_entity.name).to eq('Ruby Brasil')
      expect(community_entity.description).to eq('Nova descrição')
    end

    it 'levanta erro se nome inválido' do
      expect { community_entity.update_info(name: 'ab') }.to raise_error(ArgumentError, /curto/)
    end
  end
end