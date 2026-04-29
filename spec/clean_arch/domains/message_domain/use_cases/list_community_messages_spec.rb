require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::UseCases::ListCommunityMessages do
  let(:message_repository) { instance_double('MessageRepository') }
  let(:use_case)           { described_class.new(message_repository: message_repository) }
  let(:entities) do
    [
      CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
        id: 1, user_id: 1, community_id: 1, content: 'Mensagem 1', user_ip: '192.168.0.1'
      ),
      CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
        id: 2, user_id: 2, community_id: 1, content: 'Mensagem 2', user_ip: '192.168.0.2'
      )
    ]
  end

  describe '#call' do
    context 'quando há mensagens na comunidade' do
      before do
        allow(message_repository).to receive(:list_by_community).and_return(entities)
      end

      it 'retorna lista de MessageOutputDto' do
        output = use_case.call(community_id: 1)
        expect(output).to all(be_a(CleanArch::Domains::MessageDomain::Dtos::MessageOutputDto))
      end

      it 'retorna a quantidade correta de mensagens' do
        output = use_case.call(community_id: 1)
        expect(output.size).to eq(2)
      end
    end

    context 'quando não há mensagens' do
      before do
        allow(message_repository).to receive(:list_by_community).and_return([])
      end

      it 'retorna lista vazia' do
        output = use_case.call(community_id: 1)
        expect(output).to be_empty
      end
    end

    context 'quando community_id é inválido' do
      it 'levanta DomainError' do
        expect { use_case.call(community_id: nil) }.to raise_error(CleanArch::Domains::DomainError, /obrigatório/)
      end
    end
  end
end