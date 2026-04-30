module CleanArch
  module Domains
    module ReactionDomain
      module UseCases
        class ListMessageReactions
          def initialize(reaction_repository:)
            @reaction_repository = reaction_repository
          end

          def call(message_id:)
            raise CleanArch::Domains::DomainError, "message_id é obrigatório" if message_id.blank?

            @reaction_repository
              .list_by_message(message_id)
              .map { |entity| Dtos::ReactionOutputDto.new(entity) }
          end
        end
      end
    end
  end
end