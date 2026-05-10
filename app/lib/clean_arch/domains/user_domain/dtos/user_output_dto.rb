module CleanArch
  module Domains
    module UserDomain
      module Dtos
        UserOutputDto = OutputDto.for(
          :id, :username, :active, :created_at
        )
      end
    end
  end
end
