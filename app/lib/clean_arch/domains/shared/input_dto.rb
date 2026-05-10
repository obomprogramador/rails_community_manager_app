module CleanArch
  module Domains
    class InputDto
      include ActiveModel::Model
      include ActiveModel::Validations

      def initialize(attrs = {})
        super(attrs)
        raise ArgumentError, errors.full_messages.to_sentence if invalid?
      end
    end
  end
end
