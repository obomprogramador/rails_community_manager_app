module CleanArch
  module Domains
    module CommunityDomain
      module ValueObjects
        class CommunityName < ValueObject
          MIN_LENGTH = 3
          MAX_LENGTH = 100
          VALID_FORMAT = /\A[\w\s,\-]+\z/

          private

          def validate!(value)
            raise ArgumentError, "Nome não pode ser vazio" if value.nil? || value.strip.empty?
            raise ArgumentError, "Nome muito curto, mínimo #{MIN_LENGTH} caracteres" if value.strip.length < MIN_LENGTH
            raise ArgumentError, "Nome muito longo, máximo #{MAX_LENGTH} caracteres" if value.strip.length > MAX_LENGTH
          end

          def transform(value)
            value.strip
          end
        end
      end
    end
  end
end
