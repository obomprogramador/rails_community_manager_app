module CleanArch
  module Domains
    module CommunityDomain
      module UseCases
        class UpdateCommunity
          def initialize(community_repository:)
            @community_repository = community_repository
          end

          def call(input_dto)
            community_entity = @community_repository.find(input_dto.id)

            raise CleanArch::Domains::DomainError, "Comunidade não encontrada" if community_entity.nil?

            if input_dto.name.present?
              raise CleanArch::Domains::DomainError, "Nome já está em uso" if @community_repository.exists_by_name?(input_dto.name)
            end

            community_entity.update_info(
              name:        input_dto.name,
              description: input_dto.description
            )

            saved_entity = @community_repository.save(community_entity)

            Dtos::CommunityOutputDto.new(saved_entity)
          end
        end
      end
    end
  end
end