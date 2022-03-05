# frozen_string_literal: true

class DeepHashTransformer
  module Operation
    class << self
      def camel_case(val)
        pascal_case(val)
          .sub(/^[A-Z]/, &:downcase)
      end

      def dasherize(val)
        stringify(val)
          .tr('_', '-')
      end

      def identity(val)
        val
      end

      def pascal_case(val)
        stringify(val)
          .split(/(?=[A-Z])|[-_]/)
          .map(&:capitalize)
          .join
      end

      def stringify(val)
        val.to_s
      end

      def symbolize(val)
        val.to_sym
      end

      def underscore(val)
        stringify(val)
          .tr('-', '_')
      end

      def snake_case(val)
        stringify(val)
          .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end
    end
  end
end
