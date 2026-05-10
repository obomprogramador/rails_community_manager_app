module CleanArch
  module Domains
    module MessageDomain
      module Dtos
        MessageOutputDto = OutputDto.for(
          :id, :user_id, :username, :community_id, :community_name,
          :parent_message_id, :content, :user_ip, :sentiment_score, :created_at
        ) do
          def to_h
            {
              id: id,
              user: { id: user_id, username: username },
              community_id: community_id,
              community_name: community_name,
              parent_message_id: parent_message_id,
              content: content,
              user_ip: user_ip,
              sentiment_score: sentiment_score,
              created_at: created_at
            }
          end
        end
      end
    end
  end
end
