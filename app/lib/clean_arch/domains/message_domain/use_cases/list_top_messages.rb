module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class ListTopMessages
          def initialize(message_repository:)
            @message_repository = message_repository
          end

          def call(community_id:, limit: 10)
            parsed_limit = [[limit.to_i, 1].max, 50].min
            
            @message_repository.list_top_by_community(community_id, parsed_limit)
          end
        end
      end
    end
  end
end
