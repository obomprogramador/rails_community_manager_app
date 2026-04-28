module CleanArch
  module Domains
    module UserDomain
      module Repositories
        class UserRepository
          def find(id)
            record = User.find_by(id: id)
            return nil if record.nil?
            to_entity(record)
          end

          def find_by_username(username)
            record = User.find_by(username: username)
            return nil if record.nil?
            to_entity(record)
          end

          def exists_by_username?(username)
            User.exists?(username: username)
          end

          def create(username:)
            record = User.create!(username: username)
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise DomainError, "Erro ao criar usuário: #{e.message}"
          end

          def save(user_entity)
            record = User.find_by(id: user_entity.id)
            raise DomainError, "Usuário não encontrado" if record.nil?

            record.update!(active: user_entity.active?)
            to_entity(record)
          rescue ActiveRecord::RecordInvalid => e
            raise DomainError, "Erro ao salvar usuário: #{e.message}"
          end

          private

          def to_entity(record)
            Entities::UserEntity.new(
              id:         record.id,
              username:   record.username,
              active:     record.active,
              created_at: record.created_at
            )
          end
        end
      end
    end
  end
end