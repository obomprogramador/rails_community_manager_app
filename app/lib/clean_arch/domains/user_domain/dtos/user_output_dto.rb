module CleanArch
  module Domains
    module UserDomain
      module Dtos
        class UserOutputDto
          attr_reader :id, :username, :active, :created_at

          def initialize(user_entity)
            @id         = user_entity.id
            @username   = user_entity.username.to_s
            @active     = user_entity.active?
            @created_at = user_entity.created_at
          end

          def to_h
            {
              id:         @id,
              username:   @username,
              active:     @active,
              created_at: @created_at
            }
          end
        end
      end
    end
  end
end