module CleanArch
  module Domains
    module CommunityMemberDomain
      module UseCases
        class ListCommunityMembers
          def initialize(community_member_repository:)
            @community_member_repository = community_member_repository
          end

          def call(community_id:)
            raise CleanArch::Domains::DomainError, "É obrigatório informar uma comunidade válida!" if community_id.blank?

            members = @community_member_repository.list_by_community(community_id)

            members.map { |entity| Dtos::CommunityMemberOutputDto.new(entity) }
          end
        end
      end
    end
  end
end