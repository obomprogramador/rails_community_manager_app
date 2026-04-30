require 'rails_helper'

RSpec.describe CleanArch::Domains::ReactionDomain::UseCases::RemoveReaction do
  let(:reaction_repository) { instance_double('ReactionRepository') }
  let(:use_case)            { described_class.new(reaction_repository: reaction_repository) }
  let(:input_dto) do
    CleanArch::Domains::ReactionDomain::Dtos::RemoveReactionInputDto.new(
      message_id:    1,
      user_id:       1,
      reaction_type: 'like'
    )
  end

  describe '#call' do
    context 'quando reação existe' do
      before do
        allow(reaction_repository).to receive(:exists?).and_return(true)
        allow(reaction_repository).to receive(:delete).and_return(true)
      end

      it 'retorna true' do
        expect(use_case.call(input_dto)).to be true
      end
    end

    context 'quando reação não existe' do
      before do
        allow(reaction_repository).to receive(:exists?).and_return(false)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }
          .to raise_error(CleanArch::Domains::DomainError, /não encontrada/)
      end
    end

    context 'quando reaction_type é inválido' do
      it 'levanta ArgumentError no dto' do
        expect do
          CleanArch::Domains::ReactionDomain::Dtos::RemoveReactionInputDto.new(
            message_id:    1,
            user_id:       1,
            reaction_type: ''
          )
        end.to raise_error(ArgumentError, /obrigatório/)
      end
    end
  end
end