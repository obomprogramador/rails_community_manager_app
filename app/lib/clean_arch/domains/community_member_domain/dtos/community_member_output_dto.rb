module CleanArch
  module Domains
    module CommunityMemberDomain
      module Dtos
        class CommunityMemberOutputDto
          attr_reader :id, :community_id, :user_id, :role, :created_at

          def initialize(entity)
            @id           = entity.id
            @community_id = entity.community_id
            @user_id      = entity.user_id
            @role         = entity.role
            @created_at   = entity.created_at
          end

          def to_h
            {
              id:           @id,
              community_id: @community_id,
              user_id:      @user_id,
              role:         @role,
              created_at:   @created_at
            }
          end
        end
      end
    end
  end
end