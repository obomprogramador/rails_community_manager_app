module CleanArch
  module Domains
    module ReactionDomain
      module Repositories
        class ReactionRepository
          include RepositoryCrud

          alias create create!

          def find(message_id:, user_id:, reaction_type:)
            record = Reaction.find_by(
              message_id:    message_id,
              user_id:       user_id,
              reaction_type: reaction_type
            )
            return nil if record.nil?
            to_entity(record)
          end

          def delete(message_id:, user_id:, reaction_type:)
            record = Reaction.find_by(
              message_id:    message_id,
              user_id:       user_id,
              reaction_type: reaction_type
            )
            raise DomainError, "Reação não encontrada" if record.nil?
            record.destroy!
          end

          def list_by_message(message_id)
            Reaction.where(message_id: message_id)
                    .order(:reaction_type)
                    .map { |record| to_entity(record) }
          end

          def create_with_lock(message_id:, user_id:, reaction_type:)
            ActiveRecord::Base.transaction do
              Message.lock.find(message_id)

              raise DomainError, "Usuário já reagiu com '#{reaction_type}' nesta mensagem" if exists?(
                message_id:    message_id,
                user_id:       user_id,
                reaction_type: reaction_type
              )

              record = Reaction.create!(
                message_id:    message_id,
                user_id:       user_id,
                reaction_type: reaction_type
              )

              to_entity(record)
            end
          rescue ActiveRecord::RecordNotUnique
            raise DomainError, "Usuário já reagiu com '#{reaction_type}' nesta mensagem"
          rescue ActiveRecord::RecordInvalid => e
            raise DomainError, "Erro ao adicionar reação: #{e.message}"
          end

          def count_by_type(message_id)
            counts = Reaction.where(message_id: message_id)
                             .group(:reaction_type)
                             .count

            ValueObjects::ReactionType::TYPES.each_with_object({}) do |type, hash|
              hash[type] = counts.fetch(type, 0)
            end
          end

          private

          def model_class
            Reaction
          end

          def to_entity(record)
            Entities::ReactionEntity.new(
              id:            record.id,
              message_id:    record.message_id,
              user_id:       record.user_id,
              reaction_type: record.reaction_type,
              created_at:    record.created_at
            )
          end
        end
      end
    end
  end
end
