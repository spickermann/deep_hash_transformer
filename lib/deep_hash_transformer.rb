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

    key_ops, collection_ops = ops.partition { |op| ELEMENT_OPS.include?(op) }
    transform_value(hash, key_ops, collection_ops, {}.compare_by_identity)
  end

  OPS.each do |operation|
    define_method(operation) { tr(operation) }
  end

  private

  attr_reader :hash

  def transform_collection(collection, ops)
    ops.inject(collection) do |c, op|
      CollectionOperation.public_send(op, c)
    end
  end

  def transform_value(value, key_ops, collection_ops, ancestors)
    return value unless value.is_a?(Array) || value.is_a?(Hash)

    raise ArgumentError, "cyclic Hash/Array structure" if ancestors.key?(value)

    ancestors[value] = true
    begin
      collection = if value.is_a?(Array)
        value.map { |e| transform_value(e, key_ops, collection_ops, ancestors) }
      else
        result = {}
        value.each { |k, v| result[transform_key(k, key_ops)] = transform_value(v, key_ops, collection_ops, ancestors) }
        result
      end

      transform_collection(collection, collection_ops)
    ensure
      ancestors.delete(value)
    end
  end

  def transform_key(key, ops)
    return key unless key.is_a?(String) || key.is_a?(Symbol)

    ops.inject(key) do |k, op|
      ElementOperation.public_send(op, k)
    end
  end
end
