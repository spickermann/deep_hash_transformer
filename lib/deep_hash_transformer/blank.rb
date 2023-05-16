# frozen_string_literal: true

class DeepHashTransformer
  class Blank
    BLANK_STRING = /\A[[:space:]]*\z/.freeze

    def self.call(value)
      new(value).blank?
    end

    def initialize(value)
      @value = value
    end

    def blank?
      return true                       unless value
      return value.blank?               if value.respond_to?(:blank?)
      return BLANK_STRING.match?(value) if value.is_a?(String)
      return value.empty?               if value.respond_to?(:empty?)

      false
    end

    private

    attr_reader :value
  end
end
