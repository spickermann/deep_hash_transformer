# frozen_string_literal: true

RSpec.describe DeepHashTransformer::Blank do
  describe '.call' do
    subject { described_class.call(value) }

    presents = [true, 1, 0, 'any', [nil], { A: nil }]
    blanks   = [nil, false, '', ' ', [], {}]

    presents.each do |value|
      context "with #{value.inspect}" do
        let(:value) { value }

        it { is_expected.to be false }
      end
    end

    blanks.each do |value|
      context "with #{value.inspect}" do
        let(:value) { value }

        it { is_expected.to be true }
      end
    end
  end
end
