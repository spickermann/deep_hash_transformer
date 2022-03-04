# frozen_string_literal: true

RSpec.describe DeepHashTransformer do
  subject { described_class.new(example) }

  let(:example) do
    {
      Integer => 123,
      :symbol => { foo: 'bar' },
      'string' => { 'foo' => 123 },
      'nested-array' => [
        {
          'camelCased' => 'camelCased',
          'dashed-key' => 'dashed-key',
          'PascalCased' => 'PascalCased',
          'under_scored' => 'under_scored'
        }
      ]
    }
  end

  describe '#tr with `:snake_case, :symbolize`' do
    subject { super().tr(:snake_case, :symbolize) }

    it do # rubocop:disable RSpec/ExampleLength
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        :symbol => { foo: 'bar' },
        :string => { foo: 123 },
        :nested_array => [
          {
            camel_cased: 'camelCased',
            dashed_key: 'dashed-key',
            pascal_cased: 'PascalCased',
            under_scored: 'under_scored'
          }
        ]
      )
    end
  end

  describe '#dasherize' do
    subject { super().dasherize }

    it do # rubocop:disable RSpec/ExampleLength
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'symbol' => { 'foo' => 'bar' },
        'string' => { 'foo' => 123 },
        'nested-array' => [
          {
            'camelCased' => 'camelCased',
            'dashed-key' => 'dashed-key',
            'PascalCased' => 'PascalCased',
            'under-scored' => 'under_scored'
          }
        ]
      )
    end
  end

  describe '#identity' do
    subject { super().identity }

    it { is_expected.to eq(example) }
  end

  describe '#snake_case' do
    subject { super().snake_case }

    it do # rubocop:disable RSpec/ExampleLength
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'symbol' => { 'foo' => 'bar' },
        'string' => { 'foo' => 123 },
        'nested_array' => [
          {
            'camel_cased' => 'camelCased',
            'dashed_key' => 'dashed-key',
            'pascal_cased' => 'PascalCased',
            'under_scored' => 'under_scored'
          }
        ]
      )
    end
  end

  describe '#stringify' do
    subject { super().stringify }

    it do # rubocop:disable RSpec/ExampleLength
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'symbol' => { 'foo' => 'bar' },
        'string' => { 'foo' => 123 },
        'nested-array' => [
          {
            'camelCased' => 'camelCased',
            'dashed-key' => 'dashed-key',
            'PascalCased' => 'PascalCased',
            'under_scored' => 'under_scored'
          }
        ]
      )
    end
  end

  describe '#symbolize' do
    subject { super().symbolize }

    it do # rubocop:disable RSpec/ExampleLength
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        :symbol => { foo: 'bar' },
        :string => { foo: 123 },
        :'nested-array' => [
          {
            PascalCased: 'PascalCased',
            camelCased: 'camelCased',
            'dashed-key': 'dashed-key',
            under_scored: 'under_scored'
          }
        ]
      )
    end
  end

  describe '#underscore' do
    subject { super().underscore }

    it do # rubocop:disable RSpec/ExampleLength
      expect(subject).to eq( # rubocop:disable RSpec/NamedSubject
        Integer => 123,
        'symbol' => { 'foo' => 'bar' },
        'string' => { 'foo' => 123 },
        'nested_array' => [
          {
            'camelCased' => 'camelCased',
            'dashed_key' => 'dashed-key',
            'PascalCased' => 'PascalCased',
            'under_scored' => 'under_scored'
          }
        ]
      )
    end
  end

  it 'has a version number' do
    expect(DeepHashTransformer::VERSION).not_to be_nil
  end
end
