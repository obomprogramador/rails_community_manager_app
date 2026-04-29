module CleanArch
  module Domains
    module MessageDomain
      module ValueObjects
        class MessageContent
          MAX_LENGTH = 5000

          attr_reader :value

          def initialize(value)
            validate!(value)
            @value = value.strip.freeze
          end

          def ==(other)
            other.is_a?(MessageContent) && value == other.value
          end

          def to_s
            value
          end

          private

          def validate!(value)
            raise ArgumentError, "Conteúdo não pode ser vazio" if value.blank?
            raise ArgumentError, "Conteúdo muito longo, máximo #{MAX_LENGTH} caracteres" if value.strip.length > MAX_LENGTH
          end
        end
      end
    end
  end
end