# frozen_string_literal: true

require "deep_hash_transformer/collection_operation"
require "deep_hash_transformer/element_operation"
require "deep_hash_transformer/version"

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

  OPS = (ELEMENT_OPS + COLLECTION_OPS).freeze

  def initialize(hash)
    @hash = hash
  end

  def tr(*ops)
    ops = ops.map do |op|
      name = op.to_sym if op.is_a?(String) || op.is_a?(Symbol)
      raise ArgumentError, "unknown transformation: #{op.inspect}" unless OPS.include?(name)

      name
    end

    transform_value(hash, ops, {}.compare_by_identity)
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

  def transform_value(value, ops, ancestors)
    return transform_collection(value, ops) unless value.is_a?(Array) || value.is_a?(Hash)

    raise ArgumentError, "cyclic Hash/Array structure" if ancestors.key?(value)

    ancestors[value] = true
    begin
      collection = case value
      when Array
        value.map { |e| transform_value(e, ops, ancestors) }
      when Hash
        value.map { |k, v| [transform_key(k, ops), transform_value(v, ops, ancestors)] }.to_h
      end

      transform_collection(collection, ops)
    ensure
      ancestors.delete(value)
    end
  end

  def transform_key(key, ops)
    return key unless key.is_a?(String) || key.is_a?(Symbol)

    ops.inject(key) do |k, op|
      ELEMENT_OPS.include?(op) ? ElementOperation.public_send(op, k) : k
    end
  end
end
