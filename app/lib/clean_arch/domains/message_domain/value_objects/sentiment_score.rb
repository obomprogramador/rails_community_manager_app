module CleanArch
  module Domains
    module MessageDomain
      module ValueObjects
        class SentimentScore < ValueObject
          MIN_VALUE = -1.0
          MAX_VALUE =  1.0

          def positive?
            value > 0
          end

          def negative?
            value < 0
          end

          def neutral?
            value == 0
          end

          private

          def validate!(value)
            raise ArgumentError, "Score não pode ser nulo" if value.nil?
            raise ArgumentError, "Score deve ser entre #{MIN_VALUE} e #{MAX_VALUE}" unless value.to_f.between?(MIN_VALUE, MAX_VALUE)
          end

          def transform(value)
            value.to_f
          end
        end
      end
    end
  end
end
