# frozen_string_literal: true

RSpec.describe DeepHashTransformer::Blank, :aggregate_failures do
  describe ".call" do
    subject { described_class.call(value) }

    presents = [true, 1, 0, "any", [nil], {A: nil}]
    blanks = [nil, false, "", " ", [], {}]

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

  %w[UTF-16LE UTF-16BE UTF-32LE UTF-32BE].each do |encoding|
    it "recognizes blank #{encoding} strings" do
      expect(described_class.call(" \t\n\u00a0".encode(encoding))).to be true
      expect(described_class.call(" hello ".encode(encoding))).to be false
    end
  end

  it "does not silently discard invalid byte sequences" do
    invalid = (+"\xff").force_encoding(Encoding::UTF_8)

    expect { described_class.call(invalid) }.to raise_error(ArgumentError, /invalid/)
  end

  it "rejects incomplete UTF-16 characters" do
    invalid = (+" ").force_encoding(Encoding::UTF_16LE)

    expect { described_class.call(invalid) }.to raise_error { |error|
      expect(error).to be_a(ArgumentError).or be_a(EncodingError)
    }
  end

  it "honors a custom blank? method" do
    value = Object.new
    def value.blank?
      true
    end

    expect(described_class.call(value)).to be true
  end
end
