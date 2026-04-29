module CleanArch
  module Domains
    module CommunityMemberDomain
      module UseCases
        class PromoteMember
          def initialize(community_member_repository:)
            @community_member_repository = community_member_repository
          end

          def call(input_dto)
            entity = @community_member_repository.find(
              community_id: input_dto.community_id,
              user_id:      input_dto.user_id
            )

            raise CleanArch::Domains::DomainError, "Membro não encontrado!" if entity.nil?

            entity.promote

            saved_entity = @community_member_repository.save(entity)

            Dtos::CommunityMemberOutputDto.new(saved_entity)
          end
        end
      end
    end
  end
end