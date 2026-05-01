module CleanArch
  module Domains
    module MessageDomain
      module Dtos
        class MessageThreadRepliesOutputDto
          attr_reader :parent_message, :replies

          def initialize(parent_message:, replies:)
            @parent_message = parent_message
            @replies = replies
          end

          def to_h
            {
              parent_message: parent_message.to_h,
              replies: replies.map(&:to_h)
            }
          end
        end
      end
    end
  end
end
