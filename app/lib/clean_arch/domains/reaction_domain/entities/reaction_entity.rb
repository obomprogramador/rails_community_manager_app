module CleanArch
  module Domains
    module ReactionDomain
      module Entities
        class ReactionEntity
          attr_reader :id, :message_id, :user_id, :reaction_type, :created_at

          def initialize(id:, message_id:, user_id:, reaction_type:, created_at: Time.current)
            @id            = id
            @message_id    = message_id
            @user_id       = user_id
            @reaction_type = ValueObjects::ReactionType.new(reaction_type)
            @created_at    = created_at
          end

          def positive?
            @reaction_type.positive?
          end

          def reaction_type
            @reaction_type.to_s
          end

          def ==(other)
            other.is_a?(ReactionEntity) && id == other.id
          end
        end
      end
    end
  end
end