require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityDomain::ValueObjects::CommunityName do
  describe '#initialize' do
    context 'quando válido' do
      it 'cria com sucesso' do
        name = described_class.new('Rails Brasil')
        expect(name.value).to eq('Rails Brasil')
      end

      it 'remove espaços das bordas' do
        name = described_class.new('  Rails Brasil  ')
        expect(name.value).to eq('Rails Brasil')
      end
    end

    context 'quando inválido' do
      it 'levanta erro se vazio' do
        expect { described_class.new('') }.to raise_error(ArgumentError, /vazio/)
      end

      it 'levanta erro se muito curto' do
        expect { described_class.new('ab') }.to raise_error(ArgumentError, /curto/)
      end

      it 'levanta erro se muito longo' do
        expect { described_class.new('a' * 101) }.to raise_error(ArgumentError, /longo/)
      end

      it 'levanta erro se tem caracteres inválidos' do
        expect { described_class.new('Rails@Brasil!') }.to raise_error(ArgumentError, /inválidos/)
      end
    end
  end

  describe '#==' do
    it 'é igual quando o valor é o mesmo' do
      expect(described_class.new('Rails Brasil')).to eq(described_class.new('Rails Brasil'))
    end

    it 'é diferente quando o valor é diferente' do
      expect(described_class.new('Rails Brasil')).not_to eq(described_class.new('Ruby Brasil'))
    end
  end
end