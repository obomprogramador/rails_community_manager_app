module CleanArch
  module Domains
    module UserDomain
      module Dtos
        class RegisterUserInputDto < InputDto
          attr_accessor :username
          validates :username, presence: { message: "Username é obrigatório" }

          def initialize(attrs = {})
            attrs[:username] = attrs[:username]&.strip if attrs[:username]
            super
          end
        end
      end
    end
  end
end
