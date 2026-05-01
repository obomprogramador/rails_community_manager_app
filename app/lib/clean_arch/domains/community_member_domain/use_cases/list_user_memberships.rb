module CleanArch
    module Domains
        module CommunityMemberDomain
        module UseCases
            class ListUserMemberships
            def initialize(community_member_repository:)
                @community_member_repository = community_member_repository
            end

            def call(user_id:)
                raise CleanArch::Domains::DomainError, "É obrigatório informar um usuário válido!" if user_id.blank?

                members = @community_member_repository.list_by_user(user_id)
                members.map { |entity| Dtos::CommunityMemberOutputDto.new(entity) }
            end
            end
        end
        end
    end
end