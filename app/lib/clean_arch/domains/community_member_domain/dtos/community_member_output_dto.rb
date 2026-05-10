module CleanArch
  module Domains
    module CommunityMemberDomain
      module Dtos
        CommunityMemberOutputDto = OutputDto.for(
          :id, :community_id, :user_id, :role, :created_at
        )
      end
    end
  end
end
