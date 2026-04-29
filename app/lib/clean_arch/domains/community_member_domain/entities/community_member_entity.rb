module CleanArch
  module Domains
    module CommunityMemberDomain
      module Entities
        class CommunityMemberEntity
          attr_reader :id, :community_id, :user_id, :role, :created_at

          def initialize(id:, community_id:, user_id:, role: 'member', created_at: Time.current)
            @id           = id
            @community_id = community_id
            @user_id      = user_id
            @role         = ValueObjects::MemberRole.new(role)
            @created_at   = created_at
          end

          def promote
            raise CleanArch::Domains::DomainError, "Membro banido não pode ser promovido!" if banned?
            @role = @role.promote
          end

          def demote
            raise CleanArch::Domains::DomainError, "Membro banido não pode ser rebaixado!" if banned?
            @role = @role.demote
          end

          def ban
            raise CleanArch::Domains::DomainError, "Membro já está banido!" if banned?
            @role = ValueObjects::MemberRole.new('banned')
          end

          def banned?
            @role.banned?
          end

          def can_moderate?
            @role.can_moderate?
          end

          def role
            @role.to_s
          end

          def ==(other)
            other.is_a?(CommunityMemberEntity) && id == other.id
          end
        end
      end
    end
  end
end