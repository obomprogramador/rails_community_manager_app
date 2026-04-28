module CleanArch
  module Domains
    module CommunityDomain
      module ValueObjects
        class CommunityDescription
          MAX_LENGTH = 500

          attr_reader :value

          def initialize(value)
            validate!(value)
            @value = value&.strip.freeze
          end

          def ==(other)
            other.is_a?(CommunityDescription) && value == other.value
          end

          def to_s
            value.to_s
          end

          private

          def validate!(value)
            return if value.nil?
            raise ArgumentError, "Descrição muito longa, máximo #{MAX_LENGTH} caracteres" if value.strip.length > MAX_LENGTH
          end
        end
      end
    end
  end
end