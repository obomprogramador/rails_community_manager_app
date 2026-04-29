module CleanArch
  module Domains
    module MessageDomain
      module Repositories
        class AiRepository
          # Interface que qualquer provedor de IA deve respeitar.
          # Trocar de OpenAI para Anthropic, Gemini, etc,
          # basta criar um novo AiRepository sem tocar nos use cases.

          def analyze_sentiment(text)
            raise NotImplementedError, "#{self.class} deve implementar #analyze_sentiment"
          end
        end
      end
    end
  end
end