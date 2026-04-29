module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class ReplyToMessage
          def initialize(message_repository:)
            @message_repository = message_repository
          end

          def call(input_dto)
            parent = @message_repository.find(input_dto.parent_message_id)

            raise CleanArch::Domains::DomainError, "Mensagem pai não encontrada" if parent.nil?
            raise CleanArch::Domains::DomainError, "Não é possível responder uma resposta" if parent.reply?

            entity = @message_repository.create(
              user_id:           input_dto.user_id,
              community_id:      input_dto.community_id,
              parent_message_id: input_dto.parent_message_id,
              content:           input_dto.content,
              user_ip:           input_dto.user_ip
            )

            Dtos::MessageOutputDto.new(entity)
          end
        end
      end
    end
  end
end