module CleanArch
  module Domains
    module MessageDomain
      module Dtos
        class ReplyMessageInputDto
          attr_reader :user_id, :community_id, :parent_message_id, :content, :user_ip

          def initialize(user_id:, community_id:, parent_message_id:, content:, user_ip:)
            raise ArgumentError, "user_id é obrigatório" if user_id.blank?
            raise ArgumentError, "community_id é obrigatório" if community_id.blank?
            raise ArgumentError, "parent_message_id é obrigatório" if parent_message_id.blank?
            raise ArgumentError, "content é obrigatório" if content.blank?
            raise ArgumentError, "user_ip é obrigatório" if user_ip.blank?
            @user_id           = user_id
            @community_id      = community_id
            @parent_message_id = parent_message_id
            @content           = content.strip
            @user_ip           = user_ip.strip
          end
        end
      end
    end
  end
end