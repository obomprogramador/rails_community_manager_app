module CleanArch
  module Domains
    module UserDomain
      module ValueObjects
        class IpAddress < ValueObject
          IPV4_FORMAT = /\A(\d{1,3}\.){3}\d{1,3}\z/
          IPV6_FORMAT = /\A([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}\z/

          private

          def validate!(value)
            raise ArgumentError, "IP não pode ser vazio" if value.nil? || value.strip.empty?
            raise ArgumentError, "IP com formato inválido" unless value.match?(IPV4_FORMAT) || value.match?(IPV6_FORMAT)
          end

          def transform(value)
            value.strip
          end
        end
      end
    end
  end
end
