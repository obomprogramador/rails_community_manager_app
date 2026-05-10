module CleanArch
  module Domains
    module CommunityDomain
      module ValueObjects
        class CommunityDescription < ValueObject
          MAX_LENGTH = 500

          private

          def validate!(value)
            return if value.nil?
            raise ArgumentError, "Descrição muito longa, máximo #{MAX_LENGTH} caracteres" if value.strip.length > MAX_LENGTH
          end

          def transform(value)
            value&.strip
          end
        end
      end
    end
  end
end
