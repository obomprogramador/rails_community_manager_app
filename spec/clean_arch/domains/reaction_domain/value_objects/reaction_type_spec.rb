require 'rails_helper'

RSpec.describe CleanArch::Domains::ReactionDomain::ValueObjects::ReactionType do
  describe '#initialize' do
    context 'quando válido' do
      it 'cria like com sucesso' do
        expect(described_class.new('like').value).to eq('like')
      end

      it 'cria love com sucesso' do
        expect(described_class.new('love').value).to eq('love')
      end

      it 'cria insightful com sucesso' do
        expect(described_class.new('insightful').value).to eq('insightful')
      end

      it 'converte para downcase' do
        expect(described_class.new('LIKE').value).to eq('like')
      end
    end

    context 'quando inválido' do
      it 'levanta erro se vazio' do
        expect { described_class.new('') }.to raise_error(ArgumentError, /vazio/)
      end

      it 'levanta erro se tipo desconhecido' do
        expect { described_class.new('dislike') }.to raise_error(ArgumentError, /inválido/)
      end
    end
  end

  describe '#positive?' do
    it 'like é positivo' do
      expect(described_class.new('like').positive?).to be true
    end

    it 'love é positivo' do
      expect(described_class.new('love').positive?).to be true
    end

    it 'insightful é positivo' do
      expect(described_class.new('insightful').positive?).to be true
    end
  end

  describe '#==' do
    it 'é igual quando o valor é o mesmo' do
      expect(described_class.new('like')).to eq(described_class.new('like'))
    end

    it 'é diferente quando o valor é diferente' do
      expect(described_class.new('like')).not_to eq(described_class.new('love'))
    end
  end
end