module CleanArch
  module Domains
    module MessageDomain
      module Dtos
        class CreateMessageInputDto
          attr_reader :username, :community_id, :content, :user_ip, :parent_message_id

          def initialize(username:, community_id:, content:, user_ip:, parent_message_id: nil)
            raise ArgumentError, "username é obrigatório"     if username.blank?
            raise ArgumentError, "community_id é obrigatório" if community_id.blank?
            raise ArgumentError, "content é obrigatório"      if content.blank?
            raise ArgumentError, "user_ip é obrigatório"      if user_ip.blank?

            @username          = username.strip
            @community_id      = community_id
            @content           = content.strip
            @user_ip           = user_ip.strip
            @parent_message_id = parent_message_id.presence
          end
        end
      end
    end
  end
end