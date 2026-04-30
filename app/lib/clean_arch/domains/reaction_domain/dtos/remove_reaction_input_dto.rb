module CleanArch
  module Domains
    module ReactionDomain
      module Dtos
        class RemoveReactionInputDto
          attr_reader :message_id, :user_id, :reaction_type

          def initialize(message_id:, user_id:, reaction_type:)
            raise ArgumentError, "message_id é obrigatório" if message_id.blank?
            raise ArgumentError, "user_id é obrigatório" if user_id.blank?
            raise ArgumentError, "reaction_type é obrigatório" if reaction_type.blank?
            @message_id    = message_id
            @user_id       = user_id
            @reaction_type = reaction_type.downcase.strip
          end
        end
      end
    end
  end
end