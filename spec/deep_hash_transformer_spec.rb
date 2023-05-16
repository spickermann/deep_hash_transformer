# frozen_string_literal: true

RSpec.describe DeepHashTransformer do
  subject(:operation) { described_class.new(example) }

  let(:example) { { foo: 'bar' } }

  describe 'autogenerated methods' do
    DeepHashTransformer::ELEMENT_OPS.each do |method|
      describe ".#{method}" do
        it "delegates to `Operation.#{method}`" do
          expect(
            DeepHashTransformer::ElementOperation
          ).to receive(method).with(:foo).once # rubocop:disable RSpec/MessageSpies

          operation.public_send(method)
        end
      end
    end
  end

  describe '#tr' do
    context 'with `:snake_case, :symbolize`' do
      subject { super().tr(:snake_case, :symbolize) }

      let(:example) { { 'FooBar' => 'baz' } }

      it { is_expected.to eq(foo_bar: 'baz') }
    end

    context 'with an unknown transformation' do
      subject(:unknown_ops) { operation.tr(:unknown) }

      it 'raise an exception' do
        expect { unknown_ops }.to raise_error(ArgumentError, /unknown/)
      end
    end

    context 'with a complex, nested example' do
      subject { super().tr(:camel_case, :symbolize) }

      let(:example) do
        {
          Integer => 123,
          :symbol => { foo_bar: 'bar' },
          'string' => { 'foo_bar' => 123 },
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

      it do # rubocop:disable RSpec/ExampleLength
        is_expected.to eq( # rubocop:disable RSpec/ImplicitSubject
          Integer => 123,
          :symbol => { fooBar: 'bar' },
          :string => { fooBar: 123 },
          :nestedArray => [
            {
              camelCased: 'camelCased',
              dashedKey: 'dashed-key',
              pascalCased: 'PascalCased',
              underScored: 'under_scored'
            }
          ]
        )
      end
    end

    context 'with nil values' do
      subject { super().tr(:compact, :stringify) }

      let(:example) do
        { a: { b: ['', nil, :value], c: '', d: nil, e: true, f: false, g: 123, h: [''] } }
      end

      it do # rubocop:disable RSpec/ExampleLength
        is_expected.to eq( # rubocop:disable RSpec/ImplicitSubject
          'a' => {
            'b' => ['', :value],
            'c' => '',
            'e' => true,
            'f' => false,
            'g' => 123,
            'h' => ['']
          }
        )
      end
    end

    context 'with blank values' do
      subject { super().tr(:compact_blank, :stringify) }

      let(:example) do
        { a: { b: ['', nil, :value], c: '', d: nil, e: true, f: false, g: 123, h: [''] } }
      end

      it do # rubocop:disable RSpec/ExampleLength
        is_expected.to eq( # rubocop:disable RSpec/ImplicitSubject
          'a' => {
            'b' => [:value],
            'e' => true,
            'g' => 123
          }
        )
      end
    end

    context 'with deeply nested blank values' do
      subject { super().tr(:compact_blank) }

      let(:example) do
        { a: { b: [nil, { c: nil }] } }
      end

      it { is_expected.to eq({}) }
    end
  end

  it 'has a version number' do
    expect(DeepHashTransformer::VERSION).not_to be_nil
  end
end
