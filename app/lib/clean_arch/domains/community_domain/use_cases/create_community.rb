module CleanArch
  module Domains
    module CommunityDomain
      module UseCases
        class CreateCommunity
          def initialize(community_repository:)
            @community_repository = community_repository
          end

          def call(input_dto)
            begin
              validated_name = ValueObjects::CommunityName.new(input_dto.name)
            rescue ArgumentError => e
              raise CleanArch::Domains::DomainError, e.message
            end

            raise CleanArch::Domains::DomainError, "Nome já está em uso" if @community_repository.exists_by_name?(validated_name.value)

            community_entity = @community_repository.create(
              name:        validated_name.value,
              description: input_dto.description
            )

            Dtos::CommunityOutputDto.new(community_entity)
          end
        end
      end
    end
  end
end