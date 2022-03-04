# frozen_string_literal: true

RSpec.describe DeepHashTransformer::KeyTransformer do
  examples = [
    :symbol, 'string', 'camelCase', 'dashed-key', 'PascalCase', 'under_scored'
  ]

  subject do
    examples.map { |value| described_class.public_send(method, value) }
  end

  expected_output = {
    camel_case: %w[symbol string camelCase dashedKey pascalCase underScored],
    dasherize: %w[symbol string camelCase dashed-key PascalCase under-scored],
    identity: [:symbol, 'string', 'camelCase', 'dashed-key', 'PascalCase', 'under_scored'],
    pascal_case: %w[Symbol String CamelCase DashedKey PascalCase UnderScored],
    snake_case: %w[symbol string camel_case dashed_key pascal_case under_scored],
    stringify: %w[symbol string camelCase dashed-key PascalCase under_scored],
    symbolize: %i[symbol string camelCase dashed-key PascalCase under_scored],
    underscore: %w[symbol string camelCase dashed_key PascalCase under_scored]
  }

  DeepHashTransformer::TRANSFORMATIONS.each do |method|
    describe "##{method}" do
      let(:method) { method }

      it { is_expected.to eq(expected_output[method]) }
    end
  end
end
