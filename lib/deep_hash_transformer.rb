# frozen_string_literal: true

require 'deep_hash_transformer/collection_operation'
require 'deep_hash_transformer/element_operation'
require 'deep_hash_transformer/version'

class DeepHashTransformer
  ELEMENT_OPS = %i[
    camel_case
    dasherize
    identity
    pascal_case
    snake_case
    stringify
    symbolize
    underscore
  ].freeze

  COLLECTION_OPS = %i[
    compact
    compact_blank
  ].freeze

  OPS = ELEMENT_OPS + COLLECTION_OPS

  def initialize(hash)
    @hash = hash
  end

  def tr(*ops)
    unknown_transformations = ops.map(&:to_s) - OPS.map(&:to_s)
    if unknown_transformations.any?
      raise(
        ArgumentError, "unknown transformation(s): #{unknown_transformations.join(',')}"
      )
    end

    transform_value(hash, ops)
  end

  OPS.each do |operation|
    define_method(operation) { tr(operation) }
  end

  private

  attr_reader :hash

  def transform_collection(collection, ops)
    ops.inject(collection) do |c, op|
      COLLECTION_OPS.include?(op) ? CollectionOperation.public_send(op, c) : c
    end
  end

  def transform_value(value, ops)
    collection = case value
                 when Array
                   value.map { |e| transform_value(e, ops) }
                 when Hash
                   value.map { |k, v| [transform_key(k, ops), transform_value(v, ops)] }.to_h
                 else
                   value
                 end

    transform_collection(collection, ops)
  end

  def transform_key(key, ops)
    return key unless [String, Symbol].include?(key.class)

    ops.inject(key) do |k, op|
      ELEMENT_OPS.include?(op) ? ElementOperation.public_send(op, k) : k
    end
  end
end
