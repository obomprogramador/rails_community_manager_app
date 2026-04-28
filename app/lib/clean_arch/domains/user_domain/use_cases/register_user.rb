module CleanArch
  module Domains
    module UserDomain
      module UseCases
        class RegisterUser
          def initialize(user_repository:)
            @user_repository = user_repository
          end

          def call(input_dto)
            begin
              validated_username = ValueObjects::Username.new(input_dto.username)
            rescue ArgumentError => e
              raise CleanArch::Domains::DomainError, e.message
            end

            raise CleanArch::Domains::DomainError, "Username já está em uso" if @user_repository.exists_by_username?(validated_username.value)

            user_entity = @user_repository.create(username: validated_username.value)

            Dtos::UserOutputDto.new(user_entity)
          end
        end
      end
    end
  end
end