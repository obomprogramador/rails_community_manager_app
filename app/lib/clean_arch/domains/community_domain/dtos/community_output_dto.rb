module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        class CommunityOutputDto
          attr_reader :id, :name, :description, :total_messages, :creator_id, :created_at

          def initialize(community_entity)
            @id             = community_entity.id
            @name           = community_entity.name
            @description    = community_entity.description
            @creator_id     = community_entity.creator_id
            @total_messages = community_entity.total_messages
            @created_at     = community_entity.created_at
          end

          def to_h
            {
              id:             @id,
              name:           @name,
              description:    @description,
              total_messages: @total_messages,
              creator_id:     @creator_id,
              created_at:     @created_at
            }
          end
        end
      end
    end
  end
end