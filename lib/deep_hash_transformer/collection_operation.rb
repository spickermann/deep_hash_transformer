# frozen_string_literal: true

require_relative 'blank'

class DeepHashTransformer
  module CollectionOperation
    class << self
      def compact(val)
        case val
        when Array, Hash
          val.compact
        else
          val
        end
      end

      def compact_blank(val)
        case val
        when Array
          val.reject { |elem| Blank.call(elem) }
        when Hash
          val.reject { |_, v| Blank.call(v) }
        else
          val
        end
      end
    end
  end
end
