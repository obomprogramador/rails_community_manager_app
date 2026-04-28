module CleanArch
  module Domains
    module UserDomain
      module Entities
        class UserEntity
          attr_reader :id, :username, :active, :created_at

          def initialize(id:, username:, active: true, created_at: Time.current)
            @id         = id
            @username   = ValueObjects::Username.new(username)
            @active     = active
            @created_at = created_at
          end

          def deactivate
            raise DomainError, "Usuário já está inativo" unless active?
            @active = false
          end

          def active?
            @active
          end

          def ==(other)
            other.is_a?(UserEntity) && id == other.id
          end
        end
      end
    end
  end
end