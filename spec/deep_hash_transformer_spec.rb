# frozen_string_literal: true

RSpec.describe DeepHashTransformer, :aggregate_failures do
  subject(:operation) { described_class.new(example) }

  let(:example) { {foo: "bar"} }

  describe "named operations" do
    let(:example) { {foo_bar: "bar"} }

    {
      camel_case: {"fooBar" => "bar"},
      dasherize: {"foo-bar" => "bar"},
      identity: {foo_bar: "bar"},
      pascal_case: {"FooBar" => "bar"},
      snake_case: {"foo_bar" => "bar"},
      stringify: {"foo_bar" => "bar"},
      symbolize: {foo_bar: "bar"},
      underscore: {"foo_bar" => "bar"},
      compact: {foo_bar: "bar"},
      compact_blank: {foo_bar: "bar"}
    }.each do |method, expected|
      it "applies #{method}" do
        expect(operation.public_send(method)).to eq(expected)
      end

      it "accepts the string name #{method}" do
        expect(operation.tr(method.to_s)).to eq(expected)
      end
    end
  end

  describe "operation arguments" do
    it "accepts string names in a mixed operation list" do
      result = described_class.new({"FooBar" => 1, "Empty" => nil})
        .tr("snake_case", :symbolize, "compact")

      expect(result).to eq(foo_bar: 1)
    end

    [nil, false, 1, [], {}, :unknown, "unknown"].each do |argument|
      it "rejects #{argument.inspect} with its value in the error" do
        expect { described_class.new({}).tr(argument) }
          .to raise_error(ArgumentError, /#{Regexp.escape(argument.inspect)}/)
      end
    end

    it "rejects an object pretending to be an operation" do
      argument = Object.new
      def argument.to_s
        "stringify"
      end

      expect { described_class.new({}).tr(argument) }.to raise_error(ArgumentError)
    end

    it "rejects an invalid argument after a valid operation" do
      expect { described_class.new({}).tr(:stringify, nil) }
        .to raise_error(ArgumentError, /nil/)
    end

    context "with an unknown transformation" do
      subject(:unknown_ops) { operation.tr(:unknown) }

      it "raises an exception" do
        expect { unknown_ops }.to raise_error(ArgumentError, /unknown/)
      end
    end
  end

  describe "operation ordering and collisions" do
    it "keeps the last value at a transformed key" do
      expect(described_class.new({"a" => 1, :a => 2}).stringify).to eq("a" => 2)
    end

    [[:compact, :stringify], [:stringify, :compact]].each do |operations|
      it "resolves collisions before cleanup for #{operations.inspect}" do
        expect(described_class.new({"a" => 1, :a => nil}).tr(*operations)).to eq({})
      end
    end

    it "can clean before key conversion using separate invocations" do
      cleaned = described_class.new({"a" => 1, :a => nil}).compact

      expect(described_class.new(cleaned).stringify).to eq("a" => 1)
    end

    it "preserves the order of key operations" do
      transformer = described_class.new({"FooBar" => 1})

      expect(transformer.tr(:symbolize, :snake_case)).to eq("foo_bar" => 1)
      expect(transformer.tr(:snake_case, :symbolize)).to eq(foo_bar: 1)
    end

    context "with `:snake_case, :symbolize`" do
      subject { super().tr(:snake_case, :symbolize) }

      let(:example) { {"FooBar" => "baz"} }

      it { is_expected.to eq(foo_bar: "baz") }
    end
  end

  describe "roots and cleanup" do
    [nil, false, 0, "", " ", [], {}].each do |value|
      it "preserves a #{value.inspect} root" do
        expect(described_class.new(value).compact_blank).to eq(value)
      end
    end

    it "transforms and recursively cleans an array root" do
      input = [nil, false, {"FooBar" => 1}, [nil, {empty: " "}]]

      expect(described_class.new(input).tr(:snake_case, :compact_blank))
        .to eq([{"foo_bar" => 1}])
    end

    it "only removes nil with compact" do
      input = {a: [nil, false, " ", {}], b: {c: nil}}

      expect(described_class.new(input).compact).to eq(a: [false, " ", {}], b: {})
    end

    it "removes Unicode whitespace but retains zero and zero-width space" do
      input = ["\t\n", "\u00a0", "\u2003", "\u200b", 0]

      expect(described_class.new(input).compact_blank).to eq(["\u200b", 0])
    end

    it "removes UTF-16 whitespace while retaining nonblank encoded strings" do
      text = "hello".encode("UTF-16LE")
      input = [" \t".encode("UTF-16LE"), text]

      expect(described_class.new(input).compact_blank).to eq([text])
    end

    context "with nil values" do
      subject { super().tr(:compact, :stringify) }

      let(:example) do
        {a: {b: ["", nil, :value], c: "", d: nil, e: true, f: false, g: 123, h: [""]}}
      end

      it do # rubocop:disable RSpec/ExampleLength
        is_expected.to eq( # rubocop:disable RSpec/ImplicitSubject
          "a" => {
            "b" => ["", :value],
            "c" => "",
            "e" => true,
            "f" => false,
            "g" => 123,
            "h" => [""]
          }
        )
      end
    end

    context "with blank values" do
      subject { super().tr(:compact_blank, :stringify) }

      let(:example) do
        {a: {b: ["", nil, :value], c: "", d: nil, e: true, f: false, g: 123, h: [""]}}
      end

      it do # rubocop:disable RSpec/ExampleLength
        is_expected.to eq( # rubocop:disable RSpec/ImplicitSubject
          "a" => {
            "b" => [:value],
            "e" => true,
            "g" => 123
          }
        )
      end
    end

    context "with deeply nested blank values" do
      subject { super().tr(:compact_blank) }

      let(:example) do
        {a: {b: [nil, {c: nil}]}}
      end

      it { is_expected.to eq({}) }
    end
  end

  describe "keys" do
    it "includes String subclasses" do
      key = Class.new(String).new("FooBar")

      expect(described_class.new({key => 1}).snake_case).to eq("foo_bar" => 1)
    end

    it "leaves other key types untouched, including container keys" do
      key = [:FooBar]
      input = {17 => 1, Object => 2, key => 3}
      result = described_class.new(input).stringify

      expect(result).to eq(input)
      expect(result.keys.last).to equal(key)
    end

    it "lowercases a Unicode initial in camel_case" do
      input = {"über_name" => 1, "ÄpfelBaum" => 2}

      expect(described_class.new(input).camel_case).to eq("überName" => 1, "äpfelBaum" => 2)
    end

    it "preserves the existing acronym rules" do
      expect(described_class.new({"HTTPServer" => 1}).camel_case).to eq("hTTPServer" => 1)
    end

    context "with a complex, nested example" do
      subject { super().tr(:camel_case, :symbolize) }

      let(:example) do
        {
          Integer => 123,
          :symbol => {foo_bar: "bar"},
          "string" => {"foo_bar" => 123},
          "nested-array" => [
            {
              "camelCased" => "camelCased",
              "dashed-key" => "dashed-key",
              "PascalCased" => "PascalCased",
              "under_scored" => "under_scored"
            }
          ]
        }
      end

      it do # rubocop:disable RSpec/ExampleLength
        is_expected.to eq( # rubocop:disable RSpec/ImplicitSubject
          Integer => 123,
          :symbol => {fooBar: "bar"},
          :string => {fooBar: 123},
          :nestedArray => [
            {
              camelCased: "camelCased",
              dashedKey: "dashed-key",
              pascalCased: "PascalCased",
              underScored: "under_scored"
            }
          ]
        )
      end
    end
  end

  describe "references" do
    let(:leaf) { +"value" }
    let(:shared) { {a: leaf}.freeze }
    let(:input) { [shared, shared].freeze }
    let(:result) { described_class.new(input).identity }

    it "does not mutate frozen input collections" do
      expect(result).to eq(input)
      expect(input).to eq([{a: "value"}, {a: "value"}])
    end

    it "creates collections per occurrence" do
      expect(result).not_to equal(input)
      expect(result.first).not_to equal(shared)
      expect(result.first).not_to equal(result.last)
    end

    it "shares mutable leaves" do
      result.first[:a] << "!"

      expect(leaf).to eq("value!")
      expect(result.last[:a]).to equal(leaf)
    end

    it "copies collections even without operations" do
      copied = described_class.new(input).tr

      expect(copied).to eq(input)
      expect(copied.first).not_to equal(shared)
    end
  end

  describe "ordinary output collections" do
    it "returns base Hash and Array classes" do
      input = Class.new(Array)[Class.new(Hash)[a: 1]]
      result = described_class.new(input).identity

      expect(result).to be_an_instance_of(Array)
      expect(result.first).to be_an_instance_of(Hash)
    end

    it "does not preserve hash defaults" do
      expect(described_class.new(Hash.new(42)).identity.default).to be_nil
      expect(described_class.new(Hash.new { [] }).identity.default_proc).to be_nil
    end

    it "uses ordinary key equality even for identity hashes" do # rubocop:disable RSpec/ExampleLength
      input = {}.compare_by_identity
      input[+"a"] = 1
      input[+"a"] = 2
      result = described_class.new(input).identity

      expect(result).to eq("a" => 2)
      expect(result).not_to be_compare_by_identity
    end
  end

  describe "cycles" do
    it "rejects an array containing itself" do
      input = []
      input << input

      expect { described_class.new(input).identity }.to raise_error(ArgumentError, /cycl/i)
    end

    it "rejects a cycle across a hash and an array" do
      input = {a: []}
      input[:a] << input

      expect { described_class.new(input).compact_blank }.to raise_error(ArgumentError, /cycl/i)
    end

    it "can be reused after the input cycle is removed" do # rubocop:disable RSpec/ExampleLength
      input = {a: nil}
      input[:a] = input
      transformer = described_class.new(input)
      expect { transformer.identity }.to raise_error(ArgumentError, /cycl/i)
      input[:a] = 1

      expect(transformer.identity).to eq(a: 1)
    end
  end

  it "has a version number" do
    expect(DeepHashTransformer::VERSION).not_to be_nil
  end
end
