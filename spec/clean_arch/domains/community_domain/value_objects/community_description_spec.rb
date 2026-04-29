require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityDomain::ValueObjects::CommunityDescription do
  describe '#initialize' do
    context 'quando válido' do
      it 'cria com sucesso' do
        desc = described_class.new('Uma comunidade sobre Ruby on Rails')
        expect(desc.value).to eq('Uma comunidade sobre Ruby on Rails')
      end

      it 'aceita nil pois é opcional' do
        desc = described_class.new(nil)
        expect(desc.value).to be_nil
      end

      it 'remove espaços das bordas' do
        desc = described_class.new('  descrição  ')
        expect(desc.value).to eq('descrição')
      end
    end

    context 'quando inválido' do
      it 'levanta erro se muito longa' do
        expect { described_class.new('a' * 501) }.to raise_error(ArgumentError, /longa/)
      end
    end
  end
end