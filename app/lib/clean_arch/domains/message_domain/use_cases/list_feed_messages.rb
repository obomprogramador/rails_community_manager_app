module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class ListFeedMessages
          def initialize(message_repository:)
            @message_repository = message_repository
          end

          def call(community_ids:, limit: 50)
            return [] if community_ids.blank?

            @message_repository
              .list_feed(community_ids: community_ids, limit: limit)
              .map { |entity| Dtos::MessageOutputDto.new(entity) }
          end
        end
      end
    end
  end
end
