module CleanArch
  module Domains
    module MessageDomain
      module Dtos
        class CreateMessageInputDto < InputDto
          attr_accessor :user_id, :community_id, :content, :user_ip, :parent_message_id
          validates :user_id, :community_id, :content, :user_ip, presence: true

          def initialize(attrs = {})
            attrs[:content] = attrs[:content]&.strip if attrs[:content]
            attrs[:user_ip] = attrs[:user_ip]&.strip if attrs[:user_ip]
            super
          end
        end
      end
    end
  end
end
