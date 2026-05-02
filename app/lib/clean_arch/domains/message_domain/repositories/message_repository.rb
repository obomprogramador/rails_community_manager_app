module CleanArch
  module Domains
    module MessageDomain
      module Repositories
        class MessageRepository
          def find(id)
            record = Message.includes(:user).find_by(id: id)
            return nil if record.nil?
            to_entity(record)
          end

          def create(user_id:, community_id:, content:, user_ip:, parent_message_id: nil)
            record = Message.create!(
              user_id:           user_id,
              community_id:      community_id,
              content:           content,
              user_ip:           user_ip,
              parent_message_id: parent_message_id
            )
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise CleanArch::Domains::DomainError, "Erro ao criar mensagem: #{e.message}"
          end

          def save(entity)
            record = Message.find_by(id: entity.id)
            raise CleanArch::Domains::DomainError, "Mensagem não encontrada" if record.nil?

            record.update!(ai_sentiment_score: entity.sentiment_score)
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise CleanArch::Domains::DomainError, "Erro ao salvar mensagem: #{e.message}"
          end

          def delete(id)
            record = Message.find_by(id: id)
            raise CleanArch::Domains::DomainError, "Mensagem não encontrada" if record.nil?
            record.destroy!
          end

          def list_by_community(community_id)
            Message.where(community_id: community_id, parent_message_id: nil)
                   .order(created_at: :desc)
                   .map { |record| to_entity(record) }
          end

          def list_replies(parent_message_id)
            Message.where(parent_message_id: parent_message_id)
                   .order(created_at: :asc)
                   .map { |record| to_entity(record) }
          end

          private

          def to_entity(record)
            Entities::MessageEntity.new(
              id:                record.id,
              user_id:           record.user_id,
              username:          record.user&.username,
              community_id:      record.community_id,
              parent_message_id: record.parent_message_id,
              content:           record.content,
              user_ip:           record.user_ip,
              sentiment_score:   record.ai_sentiment_score,
              created_at:        record.created_at
            )
          end
        end
      end
    end
  end
end