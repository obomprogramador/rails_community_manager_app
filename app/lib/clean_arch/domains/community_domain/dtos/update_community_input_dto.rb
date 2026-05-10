module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        class UpdateCommunityInputDto < InputDto
          attr_accessor :id, :name, :description
          validates :id, presence: { message: "ID é obrigatório" }
          validate :at_least_one_field

          def initialize(attrs = {})
            attrs[:name] = attrs[:name]&.strip if attrs[:name]
            attrs[:description] = attrs[:description]&.strip if attrs[:description]
            super
          end

          private

          def at_least_one_field
            if name.nil? && description.nil?
              errors.add(:base, "Informe name ou description para atualizar")
            end
          end
        end
      end
    end
  end
end
