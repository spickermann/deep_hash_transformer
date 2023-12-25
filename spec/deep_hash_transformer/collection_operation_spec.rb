# frozen_string_literal: true

RSpec.describe DeepHashTransformer::CollectionOperation do
  examples = [
    {a: "b"}, {a: nil}, {a: " "}, [:foo], ["", nil]
  ]

  subject do
    examples.map { |value| described_class.public_send(method, value) }
  end

  describe ".compact" do
    let(:method) { :compact }

    expected_output = [
      {a: "b"}, {}, {a: " "}, [:foo], [""]
    ]

    it { is_expected.to eq(expected_output) }
  end

  describe ".compact_blank" do
    let(:method) { :compact_blank }

    expected_output = [
      {a: "b"}, {}, {}, [:foo], []
    ]

    it { is_expected.to eq(expected_output) }
  end
end
