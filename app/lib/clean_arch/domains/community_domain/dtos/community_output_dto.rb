module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        CommunityOutputDto = OutputDto.for(
          :id, :name, :description, :total_messages, :creator_id, :created_at
        )
      end
    end
  end
end
