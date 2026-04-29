require 'rails_helper'

RSpec.describe CleanArch::Domains::CommunityMemberDomain::Entities::CommunityMemberEntity do
  let(:entity) do
    described_class.new(id: 1, community_id: 1, user_id: 1, role: 'member')
  end

  describe '#initialize' do
    it 'cria com role member por padrão' do
      expect(entity.role).to eq('member')
    end

    it 'cria com role específico' do
      admin = described_class.new(id: 2, community_id: 1, user_id: 2, role: 'admin')
      expect(admin.role).to eq('admin')
    end
  end

  describe '#promote' do
    it 'promove member para moderator' do
      entity.promote
      expect(entity.role).to eq('moderator')
    end

    it 'promove moderator para admin' do
      moderator = described_class.new(id: 1, community_id: 1, user_id: 1, role: 'moderator')
      moderator.promote
      expect(moderator.role).to eq('admin')
    end

    it 'levanta erro ao promover membro banido' do
      entity.ban
      expect { entity.promote }.to raise_error(CleanArch::Domains::DomainError, /banido/)
    end
  end

  describe '#demote' do
    it 'rebaixa admin para moderator' do
      admin = described_class.new(id: 1, community_id: 1, user_id: 1, role: 'admin')
      admin.demote
      expect(admin.role).to eq('moderator')
    end

    it 'levanta erro ao rebaixar membro banido' do
      entity.ban
      expect { entity.demote }.to raise_error(CleanArch::Domains::DomainError, /banido/)
    end
  end

  describe '#ban' do
    it 'bane o membro' do
      entity.ban
      expect(entity.banned?).to be true
    end

    it 'levanta erro se já banido' do
      entity.ban
      expect { entity.ban }.to raise_error(CleanArch::Domains::DomainError, /já está banido/)
    end
  end

  describe '#can_moderate?' do
    it 'member não pode moderar' do
      expect(entity.can_moderate?).to be false
    end

    it 'moderator pode moderar' do
      moderator = described_class.new(id: 1, community_id: 1, user_id: 1, role: 'moderator')
      expect(moderator.can_moderate?).to be true
    end

    it 'admin pode moderar' do
      admin = described_class.new(id: 1, community_id: 1, user_id: 1, role: 'admin')
      expect(admin.can_moderate?).to be true
    end
  end
end