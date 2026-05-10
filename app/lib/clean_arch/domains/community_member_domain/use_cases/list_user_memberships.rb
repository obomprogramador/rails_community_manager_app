module CleanArch
  module Domains
    module CommunityMemberDomain
      module UseCases
        class ListUserMemberships
          def initialize(community_member_repository: CommunityMember)
            @community_member_repository = community_member_repository
          end

          def call(user_id:)
            raise CleanArch::Domains::DomainError, "É obrigatório informar um usuário válido!" if user_id.blank?

            @community_member_repository
              .list_by_user(user_id)
              .map { |record| record_to_dto(record) }
          end

          private

          def record_to_dto(record)
            Dtos::CommunityMemberOutputDto.new(
              id: record.id,
              community_id: record.community_id,
              user_id: record.user_id,
              role: record.role,
              created_at: record.created_at
            )
          end
        end
      end
    end
  end
end
