require 'rails_helper'

RSpec.describe CleanArch::Domains::UserDomain::UseCases::AuthenticateUser do
  let(:user_repository) { instance_double('UserRepository') }
  let(:use_case)        { described_class.new(user_repository: user_repository) }
  let(:input_dto) do
    CleanArch::Domains::UserDomain::Dtos::RegisterUserInputDto.new(username: 'john_doe')
  end
  let(:user_entity) do
    CleanArch::Domains::UserDomain::Entities::UserEntity.new(id: 1, username: 'john_doe')
  end

  describe '#call' do
    context 'quando usuário existe e está ativo' do
      before do
        allow(user_repository).to receive(:find_by_username).and_return(user_entity)
      end

      it 'retorna um UserOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::UserDomain::Dtos::UserOutputDto)
      end
    end

    context 'quando usuário não encontrado' do
      before do
        allow(user_repository).to receive(:find_by_username).and_return(nil)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /não encontrado/)
      end
    end

    context 'quando usuário inativo' do
      before do
        user_entity.deactivate
        allow(user_repository).to receive(:find_by_username).and_return(user_entity)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /inativo/)
      end
    end
  end
end