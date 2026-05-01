module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class ListMessageReplies
          def initialize(message_repository:)
            @message_repository = message_repository
          end

          def call(message_id:)
            raise CleanArch::Domains::DomainError, "message_id é obrigatório" if message_id.blank?
            
            parent = @message_repository.find(message_id)
            
            raise CleanArch::Domains::DomainError, "Mensagem não encontrada" if parent.nil?
            raise CleanArch::Domains::DomainError, "Mensagem não aceita respostas pois é uma resposta" if parent.reply?
            
            @message_repository
              .list_replies(message_id)
              .map { |entity| Dtos::MessageOutputDto.new(entity) }
          end
        end
      end
    end
  end
end