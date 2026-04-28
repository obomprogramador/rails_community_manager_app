require 'rails_helper'

RSpec.describe CleanArch::Domains::UserDomain::UseCases::RegisterUser do
  let(:user_repository) { instance_double('UserRepository') }
  let(:use_case)        { described_class.new(user_repository: user_repository) }
  let(:input_dto) do
    CleanArch::Domains::UserDomain::Dtos::RegisterUserInputDto.new(username: 'john_doe')
  end

  describe '#call' do
    context 'quando username disponível' do
      before do
        allow(user_repository).to receive(:exists_by_username?).and_return(false)
        allow(user_repository).to receive(:create).and_return(
          CleanArch::Domains::UserDomain::Entities::UserEntity.new(id: 1, username: 'john_doe')
        )
      end

      it 'retorna um UserOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::UserDomain::Dtos::UserOutputDto)
      end

      it 'retorna o username correto' do
        output = use_case.call(input_dto)
        expect(output.username).to eq('john_doe')
      end
    end

    context 'quando username já em uso' do
      before do
        allow(user_repository).to receive(:exists_by_username?).and_return(true)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /em uso/)
      end
    end
  end
end