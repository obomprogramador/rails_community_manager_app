module CleanArch
  module Domains
    module MessageDomain
      module ValueObjects
        class MessageContent < ValueObject
          MAX_LENGTH = 5000

          private

          def validate!(value)
            raise ArgumentError, "Conteúdo não pode ser vazio" if value.blank?
            raise ArgumentError, "Conteúdo muito longo, máximo #{MAX_LENGTH} caracteres" if value.strip.length > MAX_LENGTH
          end

          def transform(value)
            value.strip
          end
        end
      end
    end
  end
end
