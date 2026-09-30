# frozen_string_literal: true

# DHT_LIB selects an archived implementation; it never changes the working tree.
$LOAD_PATH.unshift(ENV.fetch("DHT_LIB", File.expand_path("../lib", __dir__)))
require "deep_hash_transformer"
require "json"

def clock
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

def sample(callable)
  10.times { callable.call }
  started = clock
  3.times { callable.call }
  iterations = (0.05 / ((clock - started) / 3)).ceil.clamp(3, 5_000)
  measurements = Array.new(7) do
    GC.start
    allocated = GC.stat(:total_allocated_objects)
    started = clock
    iterations.times { callable.call }
    elapsed = clock - started
    objects = GC.stat(:total_allocated_objects) - allocated
    {ms: elapsed * 1_000 / iterations, objects: objects.fdiv(iterations)}
  end
  times = measurements.map { |measurement| measurement[:ms] }.sort
  objects = measurements.map { |measurement| measurement[:objects] }.sort
  {iterations: iterations, median_ms: times[3], min_ms: times.first,
   max_ms: times.last, allocated_objects: objects[3], samples: measurements}
end

def record(index)
  {"User#{index}Name" => 1, "Empty#{index}Value" => nil,
   "Nested#{index}Array" => [{"Child#{index}Key" => 2, "Blank#{index}Key" => " "}]}
end

deep = {"LeafKey" => 1}
200.times { deep = {"NestedKey" => [deep]} }
datasets = {
  "small" => record(""),
  "wide_100" => 100.times.to_h { |i| ["Field#{i}Name", (i unless i % 7 == 0)] },
  "wide_10000" => 10_000.times.to_h { |i| ["Field#{i}Name", (i unless i % 7 == 0)] },
  "repeated_1000" => Array.new(1_000) { record("") },
  "distinct_1000" => Array.new(1_000) { |i| record(i) },
  "depth_200" => deep
}
operations = {
  stringify: [:stringify], snake_case: [:snake_case], symbolize: [:symbolize],
  compact: [:compact], compact_blank: [:compact_blank],
  combined: [:snake_case, :symbolize, :compact]
}
rows = []
datasets.each do |name, input|
  operations.each do |label, ops|
    transformer = DeepHashTransformer.new(input)
    result = sample(-> { transformer.tr(*ops) })
    rows << result.merge(dataset: name, operation: label)
    warn format("%-16s %-14s %9.3f ms %10.0f objects", name, label,
      result[:median_ms], result[:allocated_objects])
  end
end

comparisons = []
if ENV["COMPARE_ACTIVE_SUPPORT"] == "1"
  require "active_support/core_ext/hash/keys"
  %w[small wide_10000].each do |name|
    input = datasets.fetch(name)
    candidates = {
      dht: -> { DeepHashTransformer.new(input).stringify },
      active_support: -> { input.deep_transform_keys(&:to_s) }
    }
    raise "Comparison has different results" unless candidates[:dht].call == candidates[:active_support].call

    comparisons << {dataset: name, results: candidates.transform_values { |callable| sample(callable) }}
  end
end

puts JSON.pretty_generate(
  ruby: RUBY_DESCRIPTION,
  yjit: defined?(RubyVM::YJIT) ? RubyVM::YJIT.enabled? : false,
  implementation: $LOADED_FEATURES.find { |path| path.end_with?("/deep_hash_transformer.rb") },
  warmup: 10, repeats: 7, gc: "enabled; full GC before each sample",
  active_support: Gem.loaded_specs["activesupport"]&.version&.to_s,
  rows: rows, comparisons: comparisons
)
