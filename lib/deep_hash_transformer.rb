# frozen_string_literal: true

require 'deep_hash_transformer/operation'
require 'deep_hash_transformer/version'

class DeepHashTransformer
  OPS = %i[
    camel_case
    dasherize
    identity
    pascal_case
    snake_case
    stringify
    symbolize
    underscore
  ].freeze

  def initialize(hash)
    @hash = hash
  end

  def tr(*ops)
    unknown_transformtions = ops.map(&:to_s) - OPS.map(&:to_s)
    if unknown_transformtions.any?
      raise(
        ArgumentError, "unknown transformation(s): #{unknown_transformtions.join(',')}"
      )
    end

    transform_value(hash, ops)
  end

  OPS.each do |operation|
    define_method(operation) { tr(operation) }
  end

  private

  attr_reader :hash

  def transform_value(value, ops)
    case value
    when Array
      value.map { |e| transform_value(e, ops) }
    when Hash
      value.map { |k, v| [transform_key(k, ops), transform_value(v, ops)] }.to_h
    else
      value
    end
  end

  def transform_key(key, ops)
    return key unless [String, Symbol].include?(key.class)

    ops.inject(key) { |k, op| Operation.public_send(op, k) }
  end
end
