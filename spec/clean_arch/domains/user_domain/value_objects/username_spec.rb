require 'rails_helper'

RSpec.describe CleanArch::Domains::UserDomain::ValueObjects::Username do
  describe '#initialize' do
    context 'quando válido' do
      it 'cria com sucesso' do
        username = described_class.new('john_doe')
        expect(username.value).to eq('john_doe')
      end

      it 'converte para downcase' do
        username = described_class.new('JohnDoe')
        expect(username.value).to eq('johndoe')
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
        expect { described_class.new('a' * 31) }.to raise_error(ArgumentError, /longo/)
      end

      it 'levanta erro se tem caracteres inválidos' do
        expect { described_class.new('john doe!') }.to raise_error(ArgumentError, /underscores/)
      end
    end
  end
end