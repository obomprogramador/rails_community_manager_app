module CleanArch
  module Domains
    module ReactionDomain
      module Repositories
        class ReactionRepository
          def find(message_id:, user_id:, reaction_type:)
            record = Reaction.find_by(
              message_id:    message_id,
              user_id:       user_id,
              reaction_type: reaction_type
            )
            return nil if record.nil?
            to_entity(record)
          end

          def exists?(message_id:, user_id:, reaction_type:)
            Reaction.exists?(
              message_id:    message_id,
              user_id:       user_id,
              reaction_type: reaction_type
            )
          end

          def create(message_id:, user_id:, reaction_type:)
            record = Reaction.create!(
              message_id:    message_id,
              user_id:       user_id,
              reaction_type: reaction_type
            )
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise CleanArch::Domains::DomainError, "Erro ao adicionar reação: #{e.message}"
          end

          def delete(message_id:, user_id:, reaction_type:)
            record = Reaction.find_by(
              message_id:    message_id,
              user_id:       user_id,
              reaction_type: reaction_type
            )
            raise CleanArch::Domains::DomainError, "Reação não encontrada" if record.nil?
            record.destroy!
          end

          def list_by_message(message_id)
            Reaction.where(message_id: message_id)
                    .order(:reaction_type)
                    .map { |record| to_entity(record) }
          end

          private

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