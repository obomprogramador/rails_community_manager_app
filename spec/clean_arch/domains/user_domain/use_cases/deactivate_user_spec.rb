require 'rails_helper'

RSpec.describe CleanArch::Domains::UserDomain::UseCases::DeactivateUser do
  let(:user_repository) { instance_double('UserRepository') }
  let(:use_case)        { described_class.new(user_repository: user_repository) }
  let(:user_entity) do
    CleanArch::Domains::UserDomain::Entities::UserEntity.new(id: 1, username: 'john_doe')
  end

  describe '#call' do
    context 'quando usuário existe e está ativo' do
      before do
        allow(user_repository).to receive(:find).and_return(user_entity)
        allow(user_repository).to receive(:save).and_return(user_entity)
      end

      it 'desativa o usuário' do
        use_case.call(user_id: 1)
        expect(user_entity.active?).to be false
      end

      it 'retorna um UserOutputDto' do
        output = use_case.call(user_id: 1)
        expect(output).to be_a(CleanArch::Domains::UserDomain::Dtos::UserOutputDto)
      end
    end

    context 'quando usuário não encontrado' do
      before do
        allow(user_repository).to receive(:find).and_return(nil)
      end

      it 'levanta DomainError' do
        expect { use_case.call(user_id: 99) }.to raise_error(CleanArch::Domains::DomainError, /não encontrado/)
      end
    end
  end
end