require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::UseCases::PostMessage do
  let(:message_repository) { instance_double('MessageRepository') }
  let(:use_case)           { described_class.new(message_repository: message_repository) }
  let(:input_dto) do
    CleanArch::Domains::MessageDomain::Dtos::PostMessageInputDto.new(
      user_id:      1,
      community_id: 1,
      content:      'Olá comunidade!',
      user_ip:      '192.168.0.1'
    )
  end
  let(:entity) do
    CleanArch::Domains::MessageDomain::Entities::MessageEntity.new(
      id:           1,
      user_id:      1,
      community_id: 1,
      content:      'Olá comunidade!',
      user_ip:      '192.168.0.1'
    )
  end

  describe '#call' do
    context 'quando dados válidos' do
      before do
        allow(message_repository).to receive(:create).and_return(entity)
      end

      it 'retorna um MessageOutputDto' do
        output = use_case.call(input_dto)
        expect(output).to be_a(CleanArch::Domains::MessageDomain::Dtos::MessageOutputDto)
      end

      it 'retorna o conteúdo correto' do
        output = use_case.call(input_dto)
        expect(output.content).to eq('Olá comunidade!')
      end

      it 'retorna sem parent_message_id' do
        output = use_case.call(input_dto)
        expect(output.parent_message_id).to be_nil
      end
    end

    context 'quando content é vazio' do
      it 'levanta ArgumentError' do
        expect do
          CleanArch::Domains::MessageDomain::Dtos::PostMessageInputDto.new(
            user_id:      1,
            community_id: 1,
            content:      '',
            user_ip:      '192.168.0.1'
          )
        end.to raise_error(ArgumentError, /content/)
      end
    end
  end
end