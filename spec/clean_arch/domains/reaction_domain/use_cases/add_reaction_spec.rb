require 'rails_helper'

RSpec.describe CleanArch::Domains::ReactionDomain::UseCases::AddReaction do
  let(:reaction_repository) { instance_double('ReactionRepository') }
  let(:use_case)            { described_class.new(reaction_repository: reaction_repository) }
  let(:input_dto) do
    CleanArch::Domains::ReactionDomain::Dtos::AddReactionInputDto.new(
      message_id:    1,
      user_id:       1,
      reaction_type: 'like'
    )
  end
  let(:entity) do
    CleanArch::Domains::ReactionDomain::Entities::ReactionEntity.new(
      id:            1,
      message_id:    1,
      user_id:       1,
      reaction_type: 'like'
    )
  end

  describe '#call' do
    context 'quando reação ainda não existe' do
      before do
        allow(reaction_repository).to receive(:exists?).and_return(false)
        allow(reaction_repository).to receive(:create).and_return(entity)
      end

      it 'retorna um ReactionOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::ReactionDomain::Dtos::ReactionOutputDto)
      end

      it 'retorna o reaction_type correto' do
        output = use_case.call(input_dto)
        expect(output.reaction_type).to eq('like')
      end
    end

    context 'quando reação já existe' do
      before do
        allow(reaction_repository).to receive(:exists?).and_return(true)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }
          .to raise_error(CleanArch::Domains::DomainError, /já reagiu/)
      end
    end

    context 'quando reaction_type é inválido' do
      it 'levanta ArgumentError' do
        expect do
          CleanArch::Domains::ReactionDomain::Dtos::AddReactionInputDto.new(
            message_id:    1,
            user_id:       1,
            reaction_type: ''
          )
        end.to raise_error(ArgumentError, /obrigatório/)
      end
    end
  end
end