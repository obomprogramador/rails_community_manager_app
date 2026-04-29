module CleanArch
  module Domains
    module CommunityMemberDomain
      module Dtos
        class JoinCommunityInputDto
          attr_reader :community_id, :user_id

          def initialize(community_id:, user_id:)
            raise ArgumentError, "community_id é obrigatório" if community_id.blank?
            raise ArgumentError, "user_id é obrigatório" if user_id.blank?
            @community_id = community_id
            @user_id      = user_id
          end
        end
      end
    end
  end
end