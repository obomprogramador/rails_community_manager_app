module CleanArch
  module Domains
    module CommunityMemberDomain
      module ValueObjects
        class MemberRole < ValueObject
          ROLES = %w[member moderator admin banned].freeze
          PROMOTION_PATH = { 'member' => 'moderator', 'moderator' => 'admin' }.freeze
          DEMOTION_PATH  = { 'admin' => 'moderator', 'moderator' => 'member' }.freeze

          def promote
            raise CleanArch::Domains::DomainError, "Role '#{value}' não pode ser promovido" unless PROMOTION_PATH.key?(value)
            MemberRole.new(PROMOTION_PATH[value])
          end

          def demote
            raise CleanArch::Domains::DomainError, "Role '#{value}' não pode ser rebaixado" unless DEMOTION_PATH.key?(value)
            MemberRole.new(DEMOTION_PATH[value])
          end

          def banned?
            value == 'banned'
          end

          def admin?
            value == 'admin'
          end

          def moderator?
            value == 'moderator'
          end

          def member?
            value == 'member'
          end

          def can_moderate?
            moderator? || admin?
          end

          private

          def validate!(value)
            raise ArgumentError, "Role não pode ser vazio" if value.blank?
            raise ArgumentError, "Role inválido '#{value}', válidos: #{ROLES.join(', ')}" unless ROLES.include?(value.downcase)
          end

          def transform(value)
            value.downcase.strip
          end
        end
      end
    end
  end
end
