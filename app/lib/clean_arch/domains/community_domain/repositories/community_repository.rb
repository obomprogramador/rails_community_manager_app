module CleanArch
  module Domains
    module CommunityDomain
      module Repositories
        class CommunityRepository
          def find(id)
            record = Community.find_by(id: id)
            return nil if record.nil?
            to_entity(record)
          end

          def find_by_name(name)
            record = Community.find_by(name: name)
            return nil if record.nil?
            to_entity(record)
          end

          def exists_by_name?(name)
            Community.exists?(name: name)
          end

          def create(name:, creator_id:, description: nil)
            record = Community.create!(name: name, description: description, creator_id: creator_id)
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise CleanArch::Domains::DomainError, "Erro ao criar comunidade: #{e.message}"
          end

          def save(community_entity)
            record = Community.find_by(id: community_entity.id)
            raise CleanArch::Domains::DomainError, "Comunidade não encontrada" if record.nil?

            record.update!(
              name:        community_entity.name,
              description: community_entity.description
            )
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise CleanArch::Domains::DomainError, "Erro ao salvar comunidade: #{e.message}"
          end

          def all
            Community.order(:name).map { |record| to_entity(record) }
          end

          def search(query)
            Community.where("name ILIKE ?", "%#{query}%")
                     .order(:name)
                     .map { |record| to_entity(record) }
          end

          private

          def to_entity(record)
            Entities::CommunityEntity.new(
              id:          record.id,
              name:        record.name,
              description: record.description,
              creator_id:  record.creator_id,
              created_at:  record.created_at
            )
          end
        end
      end
    end
  end
end