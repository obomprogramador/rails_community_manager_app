module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        class UpdateCommunityInputDto
          attr_reader :id, :name, :description

          def initialize(id:, name: nil, description: nil)
            raise ArgumentError, "ID é obrigatório" if id.blank?
            raise ArgumentError, "Informe name ou description para atualizar" if name.nil? && description.nil?
            @id          = id
            @name        = name&.strip
            @description = description&.strip
          end
        end
      end
    end
  end
end