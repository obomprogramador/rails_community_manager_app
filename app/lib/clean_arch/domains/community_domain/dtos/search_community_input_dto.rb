module CleanArch
  module Domains
    module CommunityDomain
      module Dtos
        class SearchCommunityInputDto
          attr_reader :query

          def initialize(query:)
            raise ArgumentError, "Query não pode ser vazia" if query.blank?
            @query = query.strip
          end
        end
      end
    end
  end
end