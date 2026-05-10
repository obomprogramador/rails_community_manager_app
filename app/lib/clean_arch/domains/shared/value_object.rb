module CleanArch
  module Domains
    class ValueObject
      attr_reader :value

      def initialize(value)
        validate!(value)
        @value = transform(value)
      end

      def ==(other)
        other.is_a?(self.class) && value == other.value
      end

      alias eql? ==

      def hash
        [self.class, value].hash
      end

      def to_s
        value.to_s
      end

      def inspect
        "#<#{self.class.name} #{value.inspect}>"
      end

      private

      def validate!(value)
        if value.nil? || (value.respond_to?(:empty?) && value.empty?)
          raise ArgumentError, "Valor não pode ser vazio"
        end
      end

      def transform(value)
        value
      end
    end
  end
end
