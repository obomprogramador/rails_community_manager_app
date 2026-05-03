module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class ListCommunityMessages
          def initialize(message_repository:)
            @message_repository = message_repository
          end

          def call(community_id:)
            raise CleanArch::Domains::DomainError, "community_id é obrigatório" if community_id.blank?

            @message_repository
              .list_by_community(community_id)
              .map { |entity| Dtos::MessageOutputDto.new(entity) }
          end

          def call_paginated(community_id:, page:, per_page:)
            @message_repository
              .list_by_community_paginated(community_id, page, per_page)
          end
        end
      end
    end
  end
end