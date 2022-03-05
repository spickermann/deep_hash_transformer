# frozen_string_literal: true

RSpec.describe DeepHashTransformer::Operation do
  examples = [
    :symbol, 'string', 'camelCase', 'dashed-key', 'PascalCase', 'under_scored'
  ]

  subject do
    examples.map { |value| described_class.public_send(method, value) }
  end

  # rubocop:disable Layout/HashAlignment, Style/SymbolArray, Style/WordArray
  expected_output = {
    camel_case:  ['symbol', 'string', 'camelCase',  'dashedKey',   'pascalCase',  'underScored'],
    dasherize:   ['symbol', 'string', 'camelCase',  'dashed-key',  'PascalCase',  'under-scored'],
    identity:    [:symbol,  'string', 'camelCase',  'dashed-key',  'PascalCase',  'under_scored'],
    pascal_case: ['Symbol', 'String', 'CamelCase',  'DashedKey',   'PascalCase',  'UnderScored'],
    snake_case:  ['symbol', 'string', 'camel_case', 'dashed_key',  'pascal_case', 'under_scored'],
    stringify:   ['symbol', 'string', 'camelCase',  'dashed-key',  'PascalCase',  'under_scored'],
    symbolize:   [:symbol,  :string,  :camelCase,   :'dashed-key', :PascalCase,   :under_scored],
    underscore:  ['symbol', 'string', 'camelCase',  'dashed_key',  'PascalCase',  'under_scored']
  }
  # rubocop:enable Layout/HashAlignment, Style/SymbolArray, Style/WordArray

  DeepHashTransformer::OPS.each do |method|
    describe "##{method}" do
      let(:method) { method }

      it { is_expected.to eq(expected_output[method]) }
    end
  end
end
