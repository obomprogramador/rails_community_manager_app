module CleanArch
  module Domains
    module CommunityDomain
      module UseCases
        class SearchCommunities
          def initialize(community_repository:)
            @community_repository = community_repository
          end

          def call(input_dto)
            results = @community_repository.search(input_dto.query)

            raise CleanArch::DomainError, "Nenhuma comunidade encontrada" if results.empty?

            results.map { |entity| Dtos::CommunityOutputDto.new(entity) }
          end
        end
      end
    end
  end
end