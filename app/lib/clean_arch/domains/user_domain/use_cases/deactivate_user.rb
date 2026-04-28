module CleanArch
  module Domains
    module UserDomain
      module UseCases
        class DeactivateUser
          def initialize(user_repository:)
            @user_repository = user_repository
          end

          def call(user_id:)
            user_entity = @user_repository.find(user_id)

            raise CleanArch::Domains::DomainError, "Usuário não encontrado" if user_entity.nil?

            user_entity.deactivate

            saved_entity = @user_repository.save(user_entity)

            Dtos::UserOutputDto.new(saved_entity)
          end
        end
      end
    end
  end
end