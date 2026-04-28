module CleanArch
  module Domains
    module UserDomain
      module Dtos
        class RegisterUserInputDto
          attr_reader :username

          def initialize(username:)
            raise ArgumentError, "Username é obrigatório" if username.blank?
            @username = username.strip
          end
        end
      end
    end
  end
end