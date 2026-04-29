require 'rails_helper'

RSpec.describe CleanArch::Domains::MessageDomain::Entities::MessageEntity do
  let(:entity) do
    described_class.new(
      id:           1,
      user_id:      1,
      community_id: 1,
      content:      'Olá comunidade!',
      user_ip:      '192.168.0.1'
    )
  end

  let(:reply_entity) do
    described_class.new(
      id:                2,
      user_id:           1,
      community_id:      1,
      parent_message_id: 1,
      content:           'Respondendo mensagem!',
      user_ip:           '192.168.0.1'
    )
  end

  describe '#initialize' do
    it 'cria mensagem raiz sem parent_message_id' do
      expect(entity.parent_message_id).to be_nil
    end

    it 'cria resposta com parent_message_id' do
      expect(reply_entity.parent_message_id).to eq(1)
    end

    it 'cria sem sentiment_score por padrão' do
      expect(entity.sentiment_score).to be_nil
    end
  end

  describe '#root?' do
    it 'retorna true se mensagem raiz' do
      expect(entity.root?).to be true
    end

    it 'retorna false se é uma resposta' do
      expect(reply_entity.root?).to be false
    end
  end

  describe '#reply?' do
    it 'retorna true se é uma resposta' do
      expect(reply_entity.reply?).to be true
    end

    it 'retorna false se é mensagem raiz' do
      expect(entity.reply?).to be false
    end
  end

  describe '#update_sentiment' do
    it 'atualiza o sentiment_score' do
      entity.update_sentiment(0.8)
      expect(entity.sentiment_score).to eq(0.8)
    end

    it 'levanta erro se score inválido' do
      expect { entity.update_sentiment(2.0) }.to raise_error(ArgumentError, /entre/)
    end
  end
end