module CleanArch
  module Domains
    module CommunityDomain
      module Entities
        class CommunityEntity
          attr_reader :id, :name, :description, :total_messages, :creator_id, :created_at

          def initialize(id:, name:, creator_id:, description: nil, total_messages: 0, created_at: Time.current)
            @id             = id
            @name           = ValueObjects::CommunityName.new(name)
            @description    = ValueObjects::CommunityDescription.new(description)
            @total_messages = total_messages
            @creator_id     = creator_id
            @created_at     = created_at
          end

          def update_info(name: nil, description: nil)
            @name        = ValueObjects::CommunityName.new(name) if name.present?
            @description = ValueObjects::CommunityDescription.new(description) unless description.nil?
          end

          def name
            @name.to_s
          end

          def description
            @description.to_s
          end

          def ==(other)
            other.is_a?(CommunityEntity) && id == other.id
          end
        end
      end
    end
  end
end