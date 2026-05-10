module CleanArch
  module Domains
    module UserDomain
      module ValueObjects
        class Username < ValueObject
          MIN_LENGTH = 3
          MAX_LENGTH = 30
          VALID_FORMAT = /\A[a-zA-Z0-9_]+\z/

          private

          def validate!(value)
            raise ArgumentError, "Username não pode ser vazio" if value.nil? || value.strip.empty?
            raise ArgumentError, "Username muito curto, mínimo #{MIN_LENGTH} caracteres" if value.length < MIN_LENGTH
            raise ArgumentError, "Username muito longo, máximo #{MAX_LENGTH} caracteres" if value.length > MAX_LENGTH
            raise ArgumentError, "Username só pode conter letras, números e underscores" unless value.match?(VALID_FORMAT)
          end

          def transform(value)
            value.downcase.strip
          end
        end
      end
    end
  end
end
