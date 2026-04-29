require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::ValueObjects::MessageContent do
  describe '#initialize' do
    context 'quando válido' do
      it 'cria com sucesso' do
        content = described_class.new('Olá, tudo bem?')
        expect(content.value).to eq('Olá, tudo bem?')
      end

      it 'remove espaços das bordas' do
        content = described_class.new('  Olá  ')
        expect(content.value).to eq('Olá')
      end
    end

    context 'quando inválido' do
      it 'levanta erro se vazio' do
        expect { described_class.new('') }.to raise_error(ArgumentError, /vazio/)
      end

      it 'levanta erro se muito longo' do
        expect { described_class.new('a' * 5001) }.to raise_error(ArgumentError, /longo/)
      end
    end
  end

  describe '#==' do
    it 'é igual quando o valor é o mesmo' do
      expect(described_class.new('Olá')).to eq(described_class.new('Olá'))
    end

    it 'é diferente quando o valor é diferente' do
      expect(described_class.new('Olá')).not_to eq(described_class.new('Tchau'))
    end
  end
end