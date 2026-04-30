module CleanArch
  module Domains
    module ReactionDomain
      module Dtos
        class ReactionOutputDto
          attr_reader :id, :message_id, :user_id, :reaction_type, :created_at

          def initialize(entity)
            @id            = entity.id
            @message_id    = entity.message_id
            @user_id       = entity.user_id
            @reaction_type = entity.reaction_type
            @created_at    = entity.created_at
          end

          def to_h
            {
              id:            @id,
              message_id:    @message_id,
              user_id:       @user_id,
              reaction_type: @reaction_type,
              created_at:    @created_at
            }
          end
        end
      end
    end
  end
end