module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        class CreateCommunityInputDto
          attr_reader :name, :description

          def initialize(name:, description: nil)
            raise ArgumentError, "Nome é obrigatório" if name.blank?
            @name        = name.strip
            @description = description&.strip
          end
        end
      end
    end
  end
end