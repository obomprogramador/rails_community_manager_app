module CleanArch
  module Domains
    module ReactionDomain
      module Dtos
        class ReactionSummaryOutputDto
          attr_reader :message_id, :reactions

          def initialize(message_id:, reactions:)
            @message_id = message_id.to_i
            @reactions  = reactions
          end

          def to_h
            {
              message_id: @message_id,
              reactions:  @reactions
            }
          end
        end
      end
    end
  end
end