module CleanArch
  module Domains
    module ReactionDomain
      module UseCases
        class RemoveReaction
          def initialize(reaction_repository:)
            @reaction_repository = reaction_repository
          end

          def call(input_dto)
            validated_type = ValueObjects::ReactionType.new(input_dto.reaction_type)

            raise CleanArch::Domains::DomainError, "Reação não encontrada" unless @reaction_repository.exists?(
              message_id:    input_dto.message_id,
              user_id:       input_dto.user_id,
              reaction_type: validated_type.value
            )

            @reaction_repository.delete(
              message_id:    input_dto.message_id,
              user_id:       input_dto.user_id,
              reaction_type: validated_type.value
            )

            true
          end
        end
      end
    end
  end
end