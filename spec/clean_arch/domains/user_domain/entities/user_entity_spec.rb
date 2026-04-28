require 'rails_helper'

RSpec.describe CleanArch::Domains::UserDomain::Entities::UserEntity do
  let(:user_entity) { described_class.new(id: 1, username: 'john_doe') }

  describe '#active?' do
    it 'é ativo por padrão' do
      expect(user_entity.active?).to be true
    end
  end

  describe '#deactivate' do
    it 'desativa o usuário' do
      user_entity.deactivate
      expect(user_entity.active?).to be false
    end

    it 'levanta erro se já inativo' do
      user_entity.deactivate
      expect { user_entity.deactivate }.to raise_error(CleanArch::Domains::DomainError, /inativo/)
    end
  end
end