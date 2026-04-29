require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::UseCases::DeleteMessage do
  let(:message_repository) { instance_double('MessageRepository') }
  let(:use_case)           { described_class.new(message_repository: message_repository) }
  let(:entity) do
    CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
      id:           1,
      user_id:      1,
      community_id: 1,
      content:      'Minha mensagem',
      user_ip:      '192.168.0.1'
    )
  end

  describe '#call' do
    context 'quando mensagem existe e usuário é o dono' do
      before do
        allow(message_repository).to receive(:find).and_return(entity)
        allow(message_repository).to receive(:delete).and_return(true)
      end

      it 'retorna true' do
        expect(use_case.call(message_id: 1, requesting_user_id: 1)).to be true
      end
    end

    context 'quando mensagem não encontrada' do
      before do
        allow(message_repository).to receive(:find).and_return(nil)
      end

      it 'levanta DomainError' do
        expect { use_case.call(message_id: 99, requesting_user_id: 1) }
          .to raise_error(CleanArch::Domains::DomainError, /não encontrada/)
      end
    end

    context 'quando usuário não é o dono' do
      before do
        allow(message_repository).to receive(:find).and_return(entity)
      end

      it 'levanta DomainError' do
        expect { use_case.call(message_id: 1, requesting_user_id: 99) }
          .to raise_error(CleanArch::Domains::DomainError, /permissão/)
      end
    end

    context 'quando message_id é inválido' do
      it 'levanta DomainError' do
        expect { use_case.call(message_id: nil, requesting_user_id: 1) }
          .to raise_error(CleanArch::Domains::DomainError, /obrigatório/)
      end
    end
  end
end