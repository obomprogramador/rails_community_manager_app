module CleanArch
  module Domains
    module CommunityDomain
      module UseCases
        class ListCommunities
          def initialize(community_repository:)
            @community_repository = community_repository
          end

          def call
            @community_repository.all.map { |entity| Dtos::CommunityOutputDto.new(entity) }
          end
        end
      end
    end
  end
end