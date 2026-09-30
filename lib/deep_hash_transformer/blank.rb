# frozen_string_literal: true

class DeepHashTransformer
  class Blank
    BLANK_STRING = /\A[[:space:]]*\z/

    def self.call(value)
      new(value).blank?
    end

    def initialize(value)
      @value = value
    end

    def blank?
      return true unless value
      return value.blank? if value.respond_to?(:blank?)
      return blank_string? if value.is_a?(String)
      return value.empty? if value.respond_to?(:empty?)

      false
    end

    private

    attr_reader :value

    def blank_string?
      BLANK_STRING.match?(value)
    rescue Encoding::CompatibilityError
      BLANK_STRING.match?(value.encode(Encoding::UTF_8))
    end
  end
end
