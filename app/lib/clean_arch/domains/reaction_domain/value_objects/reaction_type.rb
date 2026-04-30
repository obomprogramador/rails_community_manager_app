module CleanArch
  module Domains
    module ReactionDomain
      module ValueObjects
        class ReactionType
          TYPES = %w[like love insightful].freeze

          attr_reader :value

          def initialize(value)
            validate!(value)
            @value = value.downcase.freeze
          end

          def positive?
            %w[like love insightful].include?(value)
          end

          def ==(other)
            other.is_a?(ReactionType) && value == other.value
          end

          def to_s
            value
          end

          private

          def validate!(value)
            raise ArgumentError, "Tipo não pode ser vazio" if value.blank?
            raise ArgumentError, "Tipo inválido '#{value}', válidos: #{TYPES.join(', ')}" unless TYPES.include?(value.downcase)
          end
        end
      end
    end
  end
end