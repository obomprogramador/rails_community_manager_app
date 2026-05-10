module CleanArch
  module Domains
    module CommunityDomain
      module UseCases
        class ListCommunities
          def initialize(community_repository: Community)
            @community_repository = community_repository
          end

          def call
            @community_repository.all.order(:name).map { |record| record_to_dto(record) }
          end

          def list_by_ids(ids:)
            return [] if ids.blank?

            @community_repository
              .list_by_ids(ids)
              .map { |record| record_to_dto(record) }
          end

          def find_by_id(id)
            raise DomainError, "id é obrigatório" if id.blank?

            record = @community_repository.find_by(id: id)
            raise DomainError, "Comunidade não encontrada" if record.nil?

            record_to_dto(record)
          end

          private

          def record_to_dto(record)
            Dtos::CommunityOutputDto.new(
              id: record.id,
              name: record.name,
              description: record.description,
              total_messages: record.total_messages,
              creator_id: record.creator_id,
              created_at: record.created_at
            )
          end
        end
      end
    end
  end
end
