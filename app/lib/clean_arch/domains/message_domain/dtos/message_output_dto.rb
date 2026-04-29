module CleanArch
  module Domains
    module MessageDomain
      module Dtos
        class MessageOutputDto
          attr_reader :id, :user_id, :community_id, :parent_message_id,
                      :content, :user_ip, :sentiment_score, :created_at

          def initialize(entity)
            @id                = entity.id
            @user_id           = entity.user_id
            @community_id      = entity.community_id
            @parent_message_id = entity.parent_message_id
            @content           = entity.content
            @user_ip           = entity.user_ip
            @sentiment_score   = entity.sentiment_score
            @created_at        = entity.created_at
          end

          def to_h
            {
              id:                @id,
              user_id:           @user_id,
              community_id:      @community_id,
              parent_message_id: @parent_message_id,
              content:           @content,
              user_ip:           @user_ip,
              sentiment_score:   @sentiment_score,
              created_at:        @created_at
            }
          end
        end
      end
    end
  end
end