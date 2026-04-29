module CleanArch
  module Domains
    module MessageDomain
      module ValueObjects
        class SentimentScore
          MIN_VALUE = -1.0
          MAX_VALUE =  1.0

          attr_reader :value

          def initialize(value)
            validate!(value)
            @value = value.to_f.freeze
          end

          def positive?
            value > 0
          end

          def negative?
            value < 0
          end

          def neutral?
            value == 0
          end

          def ==(other)
            other.is_a?(SentimentScore) && value == other.value
          end

          def to_s
            value.to_s
          end

          private

          def validate!(value)
            raise ArgumentError, "Score não pode ser nulo" if value.nil?
            raise ArgumentError, "Score deve ser entre #{MIN_VALUE} e #{MAX_VALUE}" unless value.to_f.between?(MIN_VALUE, MAX_VALUE)
          end
        end
      end
    end
  end
end