require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::UseCases::AnalyzeMessageSentiment do
  let(:message_repository) { instance_double('MessageRepository') }
  let(:ai_repository)      { instance_double('AiRepository') }
  let(:use_case) do
    described_class.new(
      message_repository: message_repository,
      ai_repository:      ai_repository
    )
  end
  let(:entity) do
    CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
      id:           1,
      user_id:      1,
      community_id: 1,
      content:      'Adorei esse framework!',
      user_ip:      '192.168.0.1'
    )
  end

  describe '#call' do
    context 'quando mensagem existe e IA retorna score válido' do
      before do
        allow(message_repository).to receive(:find).and_return(entity)
        allow(ai_repository).to receive(:analyze_sentiment).and_return(0.9)
        allow(message_repository).to receive(:save).and_return(entity)
      end

      it 'retorna um MessageOutputDto' do
        output = use_case.call(message_id: 1)
        expect(output).to be_a(CleanArch::Domains::MessageDomain::Dtos::MessageOutputDto)
      end

      it 'atualiza o sentiment_score na entidade' do
        use_case.call(message_id: 1)
        expect(entity.sentiment_score).to eq(0.9)
      end

      it 'chama o ai_repository com o conteúdo da mensagem' do
        expect(ai_repository).to receive(:analyze_sentiment).with('Adorei esse framework!')
        use_case.call(message_id: 1)
      end
    end

    context 'quando mensagem não encontrada' do
      before do
        allow(message_repository).to receive(:find).and_return(nil)
      end

      it 'levanta DomainError' do
        expect { use_case.call(message_id: 99) }
          .to raise_error(CleanArch::Domains::DomainError, /não encontrada/)
      end
    end

    context 'quando IA retorna score inválido' do
      before do
        allow(message_repository).to receive(:find).and_return(entity)
        allow(ai_repository).to receive(:analyze_sentiment).and_return(2.0)
      end

      it 'levanta ArgumentError' do
        expect { use_case.call(message_id: 1) }.to raise_error(ArgumentError, /entre/)
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