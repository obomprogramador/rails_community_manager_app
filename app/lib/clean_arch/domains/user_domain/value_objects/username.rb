module CleanArch
  module Domains
    module UserDomain
      module ValueObjects
        class Username
          MIN_LENGTH = 3
          MAX_LENGTH = 30
          VALID_FORMAT = /\A[a-zA-Z0-9_]+\z/

          attr_reader :value

          def initialize(value)
            validate!(value)
            @value = value.downcase.freeze
          end

          def ==(other)
            other.is_a?(Username) && value == other.value
          end

          def to_s
            value
          end

          private

          def validate!(value)
            raise ArgumentError, "Username não pode ser vazio" if value.nil? || value.strip.empty?
            raise ArgumentError, "Username muito curto, mínimo #{MIN_LENGTH} caracteres" if value.length < MIN_LENGTH
            raise ArgumentError, "Username muito longo, máximo #{MAX_LENGTH} caracteres" if value.length > MAX_LENGTH
            raise ArgumentError, "Username só pode conter letras, números e underscores" unless value.match?(VALID_FORMAT)
          end
        end
      end
    end
  end
end
