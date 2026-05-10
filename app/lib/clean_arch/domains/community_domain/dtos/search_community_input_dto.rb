module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        class SearchCommunityInputDto < InputDto
          attr_accessor :query
          validates :query, presence: { message: "Query não pode ser vazia" }

          def initialize(attrs = {})
            attrs[:query] = attrs[:query]&.strip if attrs[:query]
            super
          end
        end
      end
    end
  end
end
