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
end