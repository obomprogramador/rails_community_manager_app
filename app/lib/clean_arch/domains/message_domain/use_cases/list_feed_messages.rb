module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class ListFeedMessages
          def initialize(message_repository: Message)
            @message_repository = message_repository
          end

          def call(community_ids:, limit: 50)
            return [] if community_ids.blank?

            @message_repository
              .list_feed(community_ids: community_ids, limit: limit)
              .map { |record| record_to_dto(record) }
          end

          private

          def record_to_dto(record)
            Dtos::MessageOutputDto.new(
              id: record.id,
              user_id: record.user_id,
              username: record.user&.username,
              community_name: record.community&.name,
              community_id: record.community_id,
              parent_message_id: record.parent_message_id,
              content: record.content,
              user_ip: record.user_ip,
              sentiment_score: record.ai_sentiment_score,
              created_at: record.created_at
            )
          end
        end
      end
    end
  end
end
