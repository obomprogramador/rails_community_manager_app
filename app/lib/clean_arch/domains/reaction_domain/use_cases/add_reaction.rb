module CleanArch
  module Domains
    module ReactionDomain
      module UseCases
        class AddReaction
          def initialize(reaction_repository:)
            @reaction_repository = reaction_repository
          end

          def call(input_dto)
            begin
              validated_type = ValueObjects::ReactionType.new(input_dto.reaction_type)
            rescue ArgumentError => e
              raise CleanArch::Domains::DomainError, e.message
            end

            raise CleanArch::Domains::DomainError, "Usuário já reagiu com '#{validated_type}' nesta mensagem" if @reaction_repository.exists?(
              message_id:    input_dto.message_id,
              user_id:       input_dto.user_id,
              reaction_type: validated_type.value
            )

            entity = @reaction_repository.create(
              message_id:    input_dto.message_id,
              user_id:       input_dto.user_id,
              reaction_type: validated_type.value
            )

            Dtos::ReactionOutputDto.new(entity)
          end
        end
      end
    end
  end
end