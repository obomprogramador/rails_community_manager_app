module CleanArch
  module Domains
    module CommunityMemberDomain
      module Dtos
        class MemberActionInputDto < InputDto
          attr_accessor :community_id, :user_id
          validates :community_id, :user_id, presence: { message: "é obrigatório" }
        end
      end
    end
  end
end
