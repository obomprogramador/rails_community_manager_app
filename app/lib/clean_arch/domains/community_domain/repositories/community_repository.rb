module CleanArch
  module Domains
    module CommunityDomain
      module Repositories
        class CommunityRepository
          include RepositoryCrud

          alias create create!

          def exists_by_name?(name)
            exists?(name: name)
          end

          def find_by_name(name)
            record = Community.find_by(name: name)
            return nil if record.nil?
            to_entity(record)
          end

          def save(community_entity)
            record = Community.find_by(id: community_entity.id)
            raise DomainError, "Comunidade não encontrada" if record.nil?

            record.update!(
              name:        community_entity.name,
              description: community_entity.description
            )
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise DomainError, "Erro ao salvar comunidade: #{e.message}"
          end

          def all
            Community.order(:name).map { |record| to_entity(record) }
          end

          def list_by_ids(ids)
            Community.where(id: ids).order(:name).map { |record| to_entity(record) }
          end

          def search(query)
            Community.where("name ILIKE ?", "%#{query}%")
                     .order(:name)
                     .map { |record| to_entity(record) }
          end

          private

          def model_class
            Community
          end

          def to_entity(record)
            Entities::CommunityEntity.new(
              id:             record.id,
              name:           record.name,
              description:    record.description,
              total_messages: record.total_messages,
              creator_id:     record.creator_id,
              created_at:     record.created_at
            )
          end
        end
      end
    end
  end
end
