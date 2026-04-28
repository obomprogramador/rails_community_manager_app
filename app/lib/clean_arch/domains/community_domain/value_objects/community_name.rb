module CleanArch
  module Domains
    module CommunityDomain
      module ValueObjects
        class CommunityName
          MIN_LENGTH = 3
          MAX_LENGTH = 100
          VALID_FORMAT = /\A[\w\s\-]+\z/

          attr_reader :value

          def initialize(value)
            validate!(value)
            @value = value.strip.freeze
          end

          def ==(other)
            other.is_a?(CommunityName) && value == other.value
          end

          def to_s
            value
          end

          private

          def validate!(value)
            raise ArgumentError, "Nome não pode ser vazio" if value.nil? || value.strip.empty?
            raise ArgumentError, "Nome muito curto, mínimo #{MIN_LENGTH} caracteres" if value.strip.length < MIN_LENGTH
            raise ArgumentError, "Nome muito longo, máximo #{MAX_LENGTH} caracteres" if value.strip.length > MAX_LENGTH
            raise ArgumentError, "Nome contém caracteres inválidos" unless value.match?(VALID_FORMAT)
          end
        end
      end
    end
  end
end