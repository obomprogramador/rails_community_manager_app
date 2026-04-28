module CleanArch
  module Domains
    module UserDomain
      module ValueObjects
        class IpAddress
          IPV4_FORMAT = /\A(\d{1,3}\.){3}\d{1,3}\z/
          IPV6_FORMAT = /\A([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}\z/

          attr_reader :value

          def initialize(value)
            validate!(value)
            @value = value.freeze
          end

          def ==(other)
            other.is_a?(IpAddress) && value == other.value
          end

          def to_s
            value
          end

          private

          def validate!(value)
            raise ArgumentError, "IP não pode ser vazio" if value.nil? || value.strip.empty?
            raise ArgumentError, "IP com formato inválido" unless value.match?(IPV4_FORMAT) || value.match?(IPV6_FORMAT)
          end
        end
      end
    end
  end
end