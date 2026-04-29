require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityMemberDomain::ValueObjects::MemberRole do
  describe '#initialize' do
    context 'quando válido' do
      it 'cria member com sucesso' do
        expect(described_class.new('member').value).to eq('member')
      end

      it 'cria moderator com sucesso' do
        expect(described_class.new('moderator').value).to eq('moderator')
      end

      it 'cria admin com sucesso' do
        expect(described_class.new('admin').value).to eq('admin')
      end

      it 'cria banned com sucesso' do
        expect(described_class.new('banned').value).to eq('banned')
      end

      it 'converte para downcase' do
        expect(described_class.new('MEMBER').value).to eq('member')
      end
    end

    context 'quando inválido' do
      it 'levanta erro se vazio' do
        expect { described_class.new('') }.to raise_error(ArgumentError, /vazio/)
      end

      it 'levanta erro se role desconhecido' do
        expect { described_class.new('superuser') }.to raise_error(ArgumentError, /inválido/)
      end
    end
  end

  describe '#promote' do
    it 'promove member para moderator' do
      role = described_class.new('member').promote
      expect(role.value).to eq('moderator')
    end

    it 'promove moderator para admin' do
      role = described_class.new('moderator').promote
      expect(role.value).to eq('admin')
    end

    it 'levanta erro ao tentar promover admin' do
      expect { described_class.new('admin').promote }.to raise_error(CleanArch::Domains::DomainError, /promovido/)
    end

    it 'levanta erro ao tentar promover banned' do
      expect { described_class.new('banned').promote }.to raise_error(CleanArch::Domains::DomainError, /promovido/)
    end
  end

  describe '#demote' do
    it 'rebaixa admin para moderator' do
      role = described_class.new('admin').demote
      expect(role.value).to eq('moderator')
    end

    it 'rebaixa moderator para member' do
      role = described_class.new('moderator').demote
      expect(role.value).to eq('member')
    end

    it 'levanta erro ao tentar rebaixar member' do
      expect { described_class.new('member').demote }.to raise_error(CleanArch::Domains::DomainError, /rebaixado/)
    end

    it 'levanta erro ao tentar rebaixar banned' do
      expect { described_class.new('banned').demote }.to raise_error(CleanArch::Domains::DomainError, /rebaixado/)
    end
  end

  describe '#can_moderate?' do
    it 'moderator pode moderar' do
      expect(described_class.new('moderator').can_moderate?).to be true
    end

    it 'admin pode moderar' do
      expect(described_class.new('admin').can_moderate?).to be true
    end

    it 'member não pode moderar' do
      expect(described_class.new('member').can_moderate?).to be false
    end

    it 'banned não pode moderar' do
      expect(described_class.new('banned').can_moderate?).to be false
    end
  end

  describe '#==' do
    it 'é igual quando o valor é o mesmo' do
      expect(described_class.new('member')).to eq(described_class.new('member'))
    end

    it 'é diferente quando o valor é diferente' do
      expect(described_class.new('member')).not_to eq(described_class.new('admin'))
    end
  end
end