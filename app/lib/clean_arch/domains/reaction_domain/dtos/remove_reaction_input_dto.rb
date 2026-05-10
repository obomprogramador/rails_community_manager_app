module CleanArch
  module Domains
    module ReactionDomain
      module Dtos
        class RemoveReactionInputDto < InputDto
          attr_accessor :message_id, :user_id, :reaction_type
          validates :message_id, :user_id, :reaction_type, presence: true

          def initialize(attrs = {})
            attrs[:reaction_type] = attrs[:reaction_type]&.downcase&.strip if attrs[:reaction_type]
            super
          end
        end
      end
    end
  end
end
