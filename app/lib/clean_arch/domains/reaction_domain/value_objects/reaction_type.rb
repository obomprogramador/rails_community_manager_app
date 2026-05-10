module CleanArch
  module Domains
    module ReactionDomain
      module ValueObjects
        class ReactionType < ValueObject
          TYPES = %w[like love haha wow sad angry insightful].freeze

          def positive?
            TYPES.include?(value)
          end

          private

          def validate!(value)
            raise ArgumentError, "Tipo não pode ser vazio" if value.blank?
            raise ArgumentError, "Tipo inválido '#{value}', válidos: #{TYPES.join(', ')}" unless TYPES.include?(value.downcase)
          end

          def transform(value)
            value.downcase.strip
          end
        end
      end
    end
  end
end
