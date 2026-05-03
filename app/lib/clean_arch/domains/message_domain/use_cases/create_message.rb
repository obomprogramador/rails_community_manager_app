module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class CreateMessage
          def initialize(message_repository:, user_repository:)
            @message_repository = message_repository
            @user_repository    = user_repository
          end

          def call(input_dto)
            # Busca ou cria o usuário
            user = @user_repository.find_by_username(input_dto.username)

            if user.nil?
              user = @user_repository.create(username: input_dto.username)
            end

            raise CleanArch::Domains::DomainError, "Usuário inativo" unless user.active?

            # Se tem parent_message_id, valida se é mensagem raiz
            if input_dto.parent_message_id.present?
              parent = @message_repository.find(input_dto.parent_message_id)
              raise CleanArch::Domains::DomainError, "Mensagem pai não encontrada" if parent.nil?
              raise CleanArch::Domains::DomainError, "Não é possível responder uma resposta" if parent.reply?
            end

            entity = @message_repository.create(
              user_id:           user.id,
              community_id:      input_dto.community_id,
              content:           input_dto.content,
              user_ip:           input_dto.user_ip,
              parent_message_id: input_dto.parent_message_id
            )

            Dtos::MessageOutputDto.new(entity)
          end
        end
      end
    end
  end
end