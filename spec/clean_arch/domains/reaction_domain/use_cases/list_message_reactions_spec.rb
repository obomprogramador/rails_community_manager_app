require 'rails_helper'

RSpec.describe CleanArch::Domains::ReactionDomain::UseCases::ListMessageReactions do
  let(:reaction_repository) { instance_double('ReactionRepository') }
  let(:use_case)            { described_class.new(reaction_repository: reaction_repository) }
  let(:entities) do
    [
      CleanArch::Domains::ReactionDomain::Entities::ReactionEntity.new(
        id: 1, message_id: 1, user_id: 1, reaction_type: 'like'
      ),
      CleanArch::Domains::ReactionDomain::Entities::ReactionEntity.new(
        id: 2, message_id: 1, user_id: 2, reaction_type: 'love'
      ),
      CleanArch::Domains::ReactionDomain::Entities::ReactionEntity.new(
        id: 3, message_id: 1, user_id: 3, reaction_type: 'insightful'
      )
    ]
  end

  describe '#call' do
    context 'quando há reações na mensagem' do
      before do
        allow(reaction_repository).to receive(:list_by_message).and_return(entities)
      end

      it 'retorna lista de ReactionOutputDto' do
        output = use_case.call(message_id: 1)
        expect(output).to all(be_a(CleanArch::Domains::ReactionDomain::Dtos::ReactionOutputDto))
      end

      it 'retorna a quantidade correta de reações' do
        output = use_case.call(message_id: 1)
        expect(output.size).to eq(3)
      end

      it 'retorna os tipos corretos' do
        output = use_case.call(message_id: 1)
        expect(output.map(&:reaction_type)).to match_array(%w[like love insightful])
      end
    end

    context 'quando não há reações' do
      before do
        allow(reaction_repository).to receive(:list_by_message).and_return([])
      end

      it 'retorna lista vazia' do
        output = use_case.call(message_id: 1)
        expect(output).to be_empty
      end
    end

    context 'quando message_id é inválido' do
      it 'levanta DomainError' do
        expect { use_case.call(message_id: nil) }
          .to raise_error(CleanArch::Domains::DomainError, /obrigatório/)
      end
    end
  end
end