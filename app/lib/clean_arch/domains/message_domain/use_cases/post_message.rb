module CleanArch
  module Domains
    module MessageDomain
      module UseCases
        class PostMessage
          def initialize(message_repository:)
            @message_repository = message_repository
          end

          def call(input_dto)
            entity = @message_repository.create(
              user_id:      input_dto.user_id,
              community_id: input_dto.community_id,
              content:      input_dto.content,
              user_ip:      input_dto.user_ip
            )

            Dtos::MessageOutputDto.new(entity)
          end
        end
      end
    end
  end
end