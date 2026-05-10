module CleanArch
  module Domains
    module ReactionDomain
      module Dtos
        ReactionOutputDto = OutputDto.for(
          :id, :message_id, :user_id, :reaction_type, :created_at
        )
      end
    end
  end
end
