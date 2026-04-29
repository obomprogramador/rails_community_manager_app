module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class DeleteMessage
          def initialize(message_repository:)
            @message_repository = message_repository
          end

          def call(message_id:, requesting_user_id:)
            raise CleanArch::Domains::DomainError, "message_id é obrigatório" if message_id.blank?

            entity = @message_repository.find(message_id)

            raise CleanArch::Domains::DomainError, "Mensagem não encontrada" if entity.nil?
            raise CleanArch::Domains::DomainError, "Sem permissão para deletar esta mensagem" unless entity.user_id == requesting_user_id

            @message_repository.delete(message_id)

            true
          end
        end
      end
    end
  end
end