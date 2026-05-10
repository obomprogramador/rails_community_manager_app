module CleanArch
  module Domains
    module OutputDto
      def self.for(*fields, &block)
        Class.new(Data.define(*fields)) do
          define_method(:initialize) do |entity|
            entity_to_h = entity.respond_to?(:to_h) ? entity.to_h : entity
            fields_hash = entity_to_h.slice(*self.class.members)
            super(**fields_hash)
          end

          class_eval(&block) if block
        end
      end
    end
  end
end
