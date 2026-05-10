module CleanArch
  module Domains
    module CommunityMemberDomain
      module Repositories
        class CommunityMemberRepository
          include RepositoryCrud

          alias create create!

          def find(community_id:, user_id:)
            record = CommunityMember.find_by(community_id: community_id, user_id: user_id)
            return nil if record.nil?
            to_entity(record)
          end

          def save(entity)
            record = CommunityMember.find_by(community_id: entity.community_id, user_id: entity.user_id)
            raise DomainError, "Membro não encontrado" if record.nil?

            record.update!(role: entity.role)
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise DomainError, "Erro ao salvar membro: #{e.message}"
          end

          def delete(community_id:, user_id:)
            record = CommunityMember.find_by(community_id: community_id, user_id: user_id)
            raise DomainError, "Membro não encontrado" if record.nil?
            record.destroy!
          end

          def list_by_community(community_id)
            CommunityMember.where(community_id: community_id)
                           .order(:created_at)
                           .map { |record| to_entity(record) }
          end

          def list_by_user(user_id)
            CommunityMember.where(user_id: user_id)
                           .order(:created_at)
                           .map { |record| to_entity(record) }
          end

          private

          def model_class
            CommunityMember
          end

          def to_entity(record)
            Entities::CommunityMemberEntity.new(
              id:           record.id,
              community_id: record.community_id,
              user_id:      record.user_id,
              role:         record.role,
              created_at:   record.created_at
            )
          end
        end
      end
    end
  end
end
