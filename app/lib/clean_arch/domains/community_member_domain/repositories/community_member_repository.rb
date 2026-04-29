module CleanArch
  module Domains
    module CommunityMemberDomain
      module Repositories
        class CommunityMemberRepository
          def find(community_id:, user_id:)
            record = CommunityMember.find_by(community_id: community_id, user_id: user_id)
            return nil if record.nil?
            to_entity(record)
          end

          def exists?(community_id:, user_id:)
            CommunityMember.exists?(community_id: community_id, user_id: user_id)
          end

          def create(community_id:, user_id:, role: 'member')
            record = CommunityMember.create!(community_id: community_id, user_id: user_id, role: role)
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise CleanArch::Domains::DomainError, "Erro ao criar vívulo entre User(#{user_id}) e Community(#{community_id}): #{e.message}"
          end

          def save(entity)
            record = CommunityMember.find_by(community_id: entity.community_id, user_id: entity.user_id)
            raise CleanArch::Domains::DomainError, "Membro não encontrado" if record.nil?

            record.update!(role: entity.role)
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise CleanArch::Domains::DomainError, "Erro ao salvar membro: #{e.message}"
          end

          def delete(community_id:, user_id:)
            record = CommunityMember.find_by(community_id: community_id, user_id: user_id)
            raise CleanArch::Domains::DomainError, "Membro não encontrado" if record.nil?
            record.destroy!
          end

          def list_by_community(community_id)
            CommunityMember.where(community_id: community_id)
                           .order(:created_at)
                           .map { |record| to_entity(record) }
          end

          private

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