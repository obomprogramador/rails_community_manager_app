module CleanArch
  module Domains
    module CommunityMemberDomain
      module Dtos
        class JoinCommunityInputDto < InputDto
          attr_accessor :community_id, :user_id
          validates :community_id, :user_id, presence: { message: "é obrigatório" }
        end
      end
    end
  end
end
