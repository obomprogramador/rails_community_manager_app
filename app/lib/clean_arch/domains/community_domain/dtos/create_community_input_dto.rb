module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        class CreateCommunityInputDto < InputDto
          attr_accessor :name, :description, :creator_id
          validates :name, presence: { message: "Nome é obrigatório" }
          validates :creator_id, presence: { message: "É necessário estar autenticado" }

          def initialize(attrs = {})
            attrs[:name] = attrs[:name]&.strip if attrs[:name]
            attrs[:description] = attrs[:description]&.strip if attrs[:description]
            super
          end
        end
      end
    end
  end
end
