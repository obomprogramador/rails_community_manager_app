module CleanArch
  module Domains
    module RepositoryCrud
      extend ActiveSupport::Concern

      def find(id)
        record = model_class.find_by(id: id)
        record ? to_entity(record) : nil
      end

      def create!(**attrs)
        to_entity(model_class.create!(attrs))
      rescue ActiveRecord::RecordInvalid => e
        raise DomainError, "Erro ao criar #{model_class.name}: #{e.message}"
      end

      def delete!(id)
        record = model_class.find_by(id: id) or raise DomainError, "#{model_class.name} não encontrada"
        record.destroy!
      end

      def exists?(**conditions)
        model_class.exists?(conditions)
      end

      private

      def model_class
        raise NotImplementedError
      end

      def to_entity(record)
        raise NotImplementedError
      end
    end
  end
end
