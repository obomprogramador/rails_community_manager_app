module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class AnalyzeMessageSentiment
          def initialize(message_repository:, ai_repository:)
            @message_repository = message_repository
            @ai_repository      = ai_repository
          end

          def call(message_id:)
            raise CleanArch::Domains::DomainError, "message_id é obrigatório" if message_id.blank?

            entity = @message_repository.find(message_id)

            raise CleanArch::Domains::DomainError, "Mensagem não encontrada" if entity.nil?

            begin
              score = @ai_repository.analyze_sentiment(entity.content)
            rescue NotImplementedError => e
              raise CleanArch::Domains::DomainError, e.message
            end

            entity.update_sentiment(score)

            saved_entity = @message_repository.save(entity)

            Dtos::MessageOutputDto.new(saved_entity)
          end
        end
      end
    end
  end
end