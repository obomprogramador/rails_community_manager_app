module CleanArch
  module Domains
    module UserDomain
      module UseCases
        class AuthenticateUser
          def initialize(user_repository:)
            @user_repository = user_repository
          end

          def call(input_dto)
            begin
              validated_username = ValueObjects::Username.new(input_dto.username)
            rescue ArgumentError => e
              raise CleanArch::Domains::DomainError, e.message
            end

            user_entity = @user_repository.find_by_username(validated_username.value)

            raise CleanArch::Domains::DomainError, "Usuário não encontrado" if user_entity.nil?
            raise CleanArch::Domains::DomainError, "Usuário inativo" unless user_entity.active?

            Dtos::UserOutputDto.new(user_entity)
          end
        end
      end
    end
  end
end