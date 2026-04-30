require 'rails_helper'

RSpec.describe CleanArch::Domains::ReactionDomain::Entities::ReactionEntity do
  let(:entity) do
    described_class.new(
      id:            1,
      message_id:    1,
      user_id:       1,
      reaction_type: 'like'
    )
  end

  describe '#initialize' do
    it 'cria com reaction_type válido' do
      expect(entity.reaction_type).to eq('like')
    end

    it 'levanta erro se reaction_type inválido' do
      expect do
        described_class.new(
          id:            1,
          message_id:    1,
          user_id:       1,
          reaction_type: 'dislike'
        )
      end.to raise_error(ArgumentError, /inválido/)
    end
  end

  describe '#positive?' do
    it 'retorna true para like' do
      expect(entity.positive?).to be true
    end

    it 'retorna true para love' do
      love = described_class.new(id: 1, message_id: 1, user_id: 1, reaction_type: 'love')
      expect(love.positive?).to be true
    end

    it 'retorna true para insightful' do
      insightful = described_class.new(id: 1, message_id: 1, user_id: 1, reaction_type: 'insightful')
      expect(insightful.positive?).to be true
    end
  end

  describe '#==' do
    it 'é igual quando o id é o mesmo' do
      other = described_class.new(id: 1, message_id: 2, user_id: 2, reaction_type: 'love')
      expect(entity).to eq(other)
    end

    it 'é diferente quando o id é diferente' do
      other = described_class.new(id: 2, message_id: 1, user_id: 1, reaction_type: 'like')
      expect(entity).not_to eq(other)
    end
  end
end