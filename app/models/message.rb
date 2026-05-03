class Message < ApplicationRecord
  belongs_to :user
  belongs_to :community
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_message_id
  has_many :reactions

  validates :ai_sentiment_score,
    numericality: {
      greater_than_or_equal_to: -1.0,
      less_than_or_equal_to: 1.0
    },
    allow_nil: true
  
  # Estratégia para eliminar a query desnecessária ao listar as comunidades existes
  # e recuperar a quantidade de menssagens existentes naquela comunidade.
  # Caso o contador se perca, pode-se no futuro ciar um cron job para validar as quantidades
  # de froma assincrona.
  after_create :increment_total_messages_by_community
  after_destroy :decrement_total_messages_by_community
  
  private
  
  def increment_total_messages_by_community
    community.increment!(:total_messages)
  end
  
  def decrement_total_messages_by_community
    community.decrement!(:total_messages)
  end
end