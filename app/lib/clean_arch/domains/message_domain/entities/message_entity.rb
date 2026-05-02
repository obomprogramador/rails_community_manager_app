module CleanArch
  module Domains
    module MessageDomain
      module Entities
        class MessageEntity
          attr_reader :id, :user_id, :username, :community_id, :parent_message_id,
                      :content, :user_ip, :sentiment_score, :created_at

          def initialize(id:, user_id:, community_id:, content:, user_ip:,
                         username: nil, parent_message_id: nil, sentiment_score: nil, created_at: Time.current)
            @id                = id
            @user_id           = user_id
            @username          = username
            @community_id      = community_id
            @parent_message_id = parent_message_id
            @content           = ValueObjects::MessageContent.new(content)
            @user_ip           = CleanArch::Domains::UserDomain::ValueObjects::IpAddress.new(user_ip)
            @sentiment_score   = sentiment_score.nil? ? nil : ValueObjects::SentimentScore.new(sentiment_score)
            @created_at        = created_at
          end

          def reply?
            !@parent_message_id.nil?
          end

          def root?
            @parent_message_id.nil?
          end

          def update_sentiment(score)
            @sentiment_score = ValueObjects::SentimentScore.new(score)
          end

          def content
            @content.to_s
          end

          def user_ip
            @user_ip.to_s
          end

          def sentiment_score
            @sentiment_score&.value
          end

          def ==(other)
            other.is_a?(MessageEntity) && id == other.id
          end
        end
      end
    end
  end
end