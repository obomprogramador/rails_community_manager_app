module CleanArch
  module Domains
    module CommunityMemberDomain
      module UseCases
        class LeaveCommunity
          def initialize(community_member_repository:)
            @community_member_repository = community_member_repository
          end

          def call(input_dto)
            entity = @community_member_repository.find(
              community_id: input_dto.community_id,
              user_id:      input_dto.user_id
            )

            raise CleanArch::Domains::DomainError, "Usuário não é membro desta comunidade!" if entity.nil?
            raise CleanArch::Domains::DomainError, "Membro banido não pode sair, contate um administrador!" if entity.banned?

            @community_member_repository.delete(
              community_id: input_dto.community_id,
              user_id:      input_dto.user_id
            )

            true
          end
        end
      end
    end
  end
end