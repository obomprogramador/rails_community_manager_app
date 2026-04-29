require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::UseCases::ReplyToMessage do
  let(:message_repository) { instance_double('MessageRepository') }
  let(:use_case)           { described_class.new(message_repository: message_repository) }
  let(:parent_entity) do
    CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
      id:           1,
      user_id:      1,
      community_id: 1,
      content:      'Mensagem raiz',
      user_ip:      '192.168.0.1'
    )
  end
  let(:reply_entity) do
    CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
      id:                2,
      user_id:           2,
      community_id:      1,
      parent_message_id: 1,
      content:           'Respondendo!',
      user_ip:           '192.168.0.2'
    )
  end
  let(:input_dto) do
    CleanArch::Domains::MessageDomain::Dtos::ReplyMessageInputDto.new(
      user_id:           2,
      community_id:      1,
      parent_message_id: 1,
      content:           'Respondendo!',
      user_ip:           '192.168.0.2'
    )
  end

  describe '#call' do
    context 'quando mensagem pai existe e é raiz' do
      before do
        allow(message_repository).to receive(:find).and_return(parent_entity)
        allow(message_repository).to receive(:create).and_return(reply_entity)
      end

      it 'retorna um MessageOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::MessageDomain::Dtos::MessageOutputDto)
      end

      it 'retorna com parent_message_id correto' do
        output = use_case.call(input_dto)
        expect(output.parent_message_id).to eq(1)
      end
    end

    context 'quando mensagem pai não encontrada' do
      before do
        allow(message_repository).to receive(:find).and_return(nil)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /não encontrada/)
      end
    end

    context 'quando tenta responder uma resposta' do
      before do
        allow(message_repository).to receive(:find).and_return(reply_entity)
      end

      it 'levanta DomainError' do
        expect { use_case.call(input_dto) }.to raise_error(CleanArch::Domains::DomainError, /responder uma resposta/)
      end
    end
  end
end