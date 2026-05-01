require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::UseCases::ListMessageReplies do
  let(:message_repository) { instance_double('MessageRepository') }
  let(:use_case)           { described_class.new(message_repository: message_repository) }
  let(:parent_entity) do
    CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
      id: 1, user_id: 1, community_id: 1, content: 'Mensagem raiz', user_ip: '192.168.0.1'
    )
  end
  let(:reply_entities) do
    [
      CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
        id: 2, user_id: 2, community_id: 1, parent_message_id: 1,
        content: 'Resposta 1', user_ip: '192.168.0.2'
      ),
      CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
        id: 3, user_id: 3, community_id: 1, parent_message_id: 1,
        content: 'Resposta 2', user_ip: '192.168.0.3'
      )
    ]
  end

  describe '#call' do
    context 'quando mensagem raiz existe e tem respostas' do
      before do
        allow(message_repository).to receive(:find).and_return(parent_entity)
        allow(message_repository).to receive(:list_replies).and_return(reply_entities)
      end

      it 'retorna MessageThreadRepliesOutputDto' do
        output = use_case.call(message_id: 1)
        expect(output).to be_a(CleanArch::Domains::MessageDomain::Dtos::MessageThreadRepliesOutputDto)
      end

      it 'retorna mensagem pai e respostas como MessageOutputDto' do
        output = use_case.call(message_id: 1)
        expect(output.parent_message).to be_a(CleanArch::Domains::MessageDomain::Dtos::MessageOutputDto)
        expect(output.parent_message.id).to eq(1)
        expect(output.replies).to all(be_a(CleanArch::Domains::MessageDomain::Dtos::MessageOutputDto))
        expect(output.replies.size).to eq(2)
      end
    end

    context 'quando mensagem não encontrada' do
      before do
        allow(message_repository).to receive(:find).and_return(nil)
      end

      it 'levanta DomainError' do
        expect { use_case.call(message_id: 99) }.to raise_error(CleanArch::Domains::DomainError, /não encontrada/)
      end
    end

    context 'quando tenta listar respostas de uma resposta' do
      let(:reply_entity) do
        CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
          id: 2, user_id: 1, community_id: 1, parent_message_id: 1,
          content: 'Sou uma resposta', user_ip: '192.168.0.1'
        )
      end

      before do
        allow(message_repository).to receive(:find).and_return(reply_entity)
      end

      it 'levanta DomainError' do
        expect { use_case.call(message_id: 2) }.to raise_error(CleanArch::Domains::DomainError, /é uma resposta/)
      end
    end

    context 'quando message_id é inválido' do
      it 'levanta DomainError' do
        expect { use_case.call(message_id: nil) }.to raise_error(CleanArch::Domains::DomainError, /obrigatório/)
      end
    end
  end
end