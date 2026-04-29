require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::ValueObjects::SentimentScore do
  describe '#initialize' do
    context 'quando válido' do
      it 'cria com score positivo' do
        expect(described_class.new(0.8).value).to eq(0.8)
      end

      it 'cria com score negativo' do
        expect(described_class.new(-0.5).value).to eq(-0.5)
      end

      it 'cria com score neutro' do
        expect(described_class.new(0.0).value).to eq(0.0)
      end

      it 'aceita valor no limite mínimo' do
        expect(described_class.new(-1.0).value).to eq(-1.0)
      end

      it 'aceita valor no limite máximo' do
        expect(described_class.new(1.0).value).to eq(1.0)
      end
    end

    context 'quando inválido' do
      it 'levanta erro se nil' do
        expect { described_class.new(nil) }.to raise_error(ArgumentError, /nulo/)
      end

      it 'levanta erro se abaixo do mínimo' do
        expect { described_class.new(-1.1) }.to raise_error(ArgumentError, /entre/)
      end

      it 'levanta erro se acima do máximo' do
        expect { described_class.new(1.1) }.to raise_error(ArgumentError, /entre/)
      end
    end
  end

  describe '#positive?' do
    it 'retorna true se score maior que zero' do
      expect(described_class.new(0.5).positive?).to be true
    end

    it 'retorna false se score menor ou igual a zero' do
      expect(described_class.new(-0.5).positive?).to be false
    end
  end

  describe '#negative?' do
    it 'retorna true se score menor que zero' do
      expect(described_class.new(-0.5).negative?).to be true
    end

    it 'retorna false se score maior ou igual a zero' do
      expect(described_class.new(0.5).negative?).to be false
    end
  end

  describe '#neutral?' do
    it 'retorna true se score igual a zero' do
      expect(described_class.new(0.0).neutral?).to be true
    end

    it 'retorna false se score diferente de zero' do
      expect(described_class.new(0.5).neutral?).to be false
    end
  end
end