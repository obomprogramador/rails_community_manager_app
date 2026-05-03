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

          def find_by_id(id)
            raise CleanArch::DomainError, "id é obrigatório" if id.blank?

            entity = @community_repository.find(id)

            raise CleanArch::DomainError, "Comunidade não encontrada" if entity.nil?

            Dtos::CommunityOutputDto.new(entity)
          end
        end
      end
    end
  end
end