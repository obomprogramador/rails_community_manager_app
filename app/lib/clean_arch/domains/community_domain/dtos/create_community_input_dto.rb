module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        class CreateCommunityInputDto
          attr_reader :name, :description, :creator_id

          def initialize(name:, creator_id:, description: nil)
            raise ArgumentError, "Nome é obrigatório" if name.blank?
            raise ArgumentError, "É necessário estar autenticado para criar uma comunidade" if creator_id.blank?

            @name        = name.strip
            @description = description&.strip
            @creator_id  = creator_id
          end
        end
      end
    end
  end
end