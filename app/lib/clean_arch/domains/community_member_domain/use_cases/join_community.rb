module CleanArch
  module Domains
    module CommunityMemberDomain
      module UseCases
        class JoinCommunity
          def initialize(community_member_repository:)
            @community_member_repository = community_member_repository
          end

          def call(input_dto)
            raise CleanArch::Domains::DomainError, "Usuário já é membro desta comunidade!" if @community_member_repository.exists?(
              community_id: input_dto.community_id,
              user_id:      input_dto.user_id
            )

            entity = @community_member_repository.create(
              community_id: input_dto.community_id,
              user_id:      input_dto.user_id
            )

            Dtos::CommunityMemberOutputDto.new(entity)
          end
        end
      end
    end
  end
end