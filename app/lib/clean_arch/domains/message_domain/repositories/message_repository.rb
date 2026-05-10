module CleanArch
  module Domains
    module MessageDomain
      module Repositories
        class MessageRepository
          include RepositoryCrud

          alias create create!

          def save(entity)
            record = Message.find_by(id: entity.id)
            raise DomainError, "Mensagem não encontrada" if record.nil?

            record.update!(ai_sentiment_score: entity.sentiment_score)
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise DomainError, "Erro ao salvar mensagem: #{e.message}"
          end

          def list_by_community(community_id)
            Message.where(community_id: community_id, parent_message_id: nil)
                   .order(created_at: :desc)
                   .map { |record| to_entity(record) }
          end

          def list_by_community_paginated(community_id, page, per_page)
            Message.includes(:user)
                  .where(community_id: community_id, parent_message_id: nil)
                  .order(created_at: :desc)
                  .offset((page - 1) * per_page)
                  .limit(per_page)
                  .map { |record| to_entity(record) }
          end

          def list_top_by_community(community_id, limit)
            Message.includes(:user)
                  .where(community_id: community_id, parent_message_id: nil)
                  .order(engagement_score: :desc)
                  .limit(limit)
                  .map { |record| to_entity(record) }
          end

          def list_replies(parent_message_id)
            Message.where(parent_message_id: parent_message_id)
                   .order(created_at: :asc)
                   .map { |record| to_entity(record) }
          end

          def list_feed(community_ids:, limit: 50)
            Message.includes(:user, :community)
                   .where(parent_message_id: nil, community_id: community_ids)
                   .order(created_at: :desc)
                   .limit(limit)
                   .map { |record| to_entity(record) }
          end

          private

          def model_class
            Message
          end

          def to_entity(record)
            Entities::MessageEntity.new(
              id:                record.id,
              user_id:           record.user_id,
              username:          record.user&.username,
              community_name:    record.community&.name,
              community_id:      record.community_id,
              parent_message_id: record.parent_message_id,
              content:           record.content,
              user_ip:           record.user_ip,
              sentiment_score:   record.ai_sentiment_score,
              created_at:        record.created_at,
              reactions_count:    record.try(:reactions_count) || 0,
              replies_count:       record.try(:replies_count) || 0,
              engagement_score:  record.try(:engagement_score) || 0.0
            )
          end
        end
      end
    end
  end
end
