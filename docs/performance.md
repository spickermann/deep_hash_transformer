# Performance measurements

Measured on 2026-09-30 on macOS 27.0.1 (Apple Silicon), with Ruby 4.0.6
(target arm64-darwin25), YJIT disabled.
The baseline is the 2.2.1 implementation at commit
`8aa4a6083d30f885ccdb7bbd1c71b258a5e6570f`. The candidate is the prepared 3.0.0
implementation, including validation and cycle detection. No background Ruby
build or test process was running during this final pair of measurements.

## Method

`script/benchmark.rb` generates inputs outside the timed section, warms each case
with ten calls, calibrates iteration count to about 50 ms (3–5,000 iterations),
and collects seven samples. GC remains enabled, with a full GC before each sample.
Tables report the median per call; the JSON files include all samples, min/max,
iteration counts, runtime details and allocation counts. Allocations count Ruby
objects via `GC.stat(:total_allocated_objects)`, not bytes or peak RSS. These are
local observations on a shared workstation, not universal speed guarantees.

The six fixtures cover small nested data, hashes with 100 and 10,000 keys,
1,000 independent records with repeated or distinct keys, and 200 hash/array
pairs of nesting. Repeated/distinct records have the same shape. Both single
operations and `snake_case, symbolize, compact` are measured. The symbol lifetime
and GC can affect allocation results; keys are not globally cached.

## Results

| Fixture | Operation | 2.2.1 ms | 3.0.0 ms | Less time | Objects old → new |
|---|---|---:|---:|---:|---:|
| small | stringify | 0.0054 | 0.0039 | 28.8% | 51 → 27 |
| small | snake_case | 0.0114 | 0.0099 | 13.4% | 96 → 72 |
| small | symbolize | 0.0053 | 0.0041 | 23.2% | 51 → 27 |
| small | compact | 0.0060 | 0.0040 | 33.6% | 54 → 30 |
| small | compact_blank | 0.0077 | 0.0058 | 25.3% | 60 → 36 |
| small | combined | 0.0153 | 0.0115 | 25.3% | 101 → 75 |
| wide_100 | stringify | 0.0635 | 0.0379 | 40.3% | 520 → 211 |
| wide_100 | snake_case | 0.1887 | 0.1523 | 19.3% | 1220 → 914 |
| wide_100 | symbolize | 0.0679 | 0.0419 | 38.2% | 520 → 213 |
| wide_100 | compact | 0.0702 | 0.0284 | 59.5% | 521 → 212 |
| wide_100 | compact_blank | 0.0923 | 0.0520 | 43.7% | 621 → 312 |
| wide_100 | combined | 0.2426 | 0.1653 | 31.8% | 1223 → 912 |
| wide_10000 | stringify | 6.4445 | 3.7183 | 42.3% | 50020 → 20011 |
| wide_10000 | snake_case | 19.6083 | 16.7030 | 14.8% | 120020 → 93344 |
| wide_10000 | symbolize | 7.4334 | 7.3570 | 1.0% | 50020 → 32812 |
| wide_10000 | compact | 7.0211 | 2.6136 | 62.8% | 50021 → 20012 |
| wide_10000 | compact_blank | 9.2318 | 4.8646 | 47.3% | 60021 → 30012 |
| wide_10000 | combined | 26.6530 | 17.1153 | 35.8% | 120023 → 90012 |
| repeated_1000 | stringify | 4.2048 | 3.0424 | 27.6% | 36018 → 19011 |
| repeated_1000 | snake_case | 10.1772 | 8.8008 | 13.5% | 81018 → 64012 |
| repeated_1000 | symbolize | 4.5308 | 3.1776 | 29.9% | 36018 → 19012 |
| repeated_1000 | compact | 4.8806 | 3.2891 | 32.6% | 39019 → 22012 |
| repeated_1000 | compact_blank | 7.0096 | 5.2429 | 25.2% | 46019 → 29012 |
| repeated_1000 | combined | 13.6252 | 10.3708 | 23.9% | 84022 → 67012 |
| distinct_1000 | stringify | 4.2521 | 3.2405 | 23.8% | 36018 → 19011 |
| distinct_1000 | snake_case | 11.0874 | 10.1306 | 8.6% | 71018 → 57060 |
| distinct_1000 | symbolize | 4.9574 | 4.4100 | 11.0% | 36018 → 22021 |
| distinct_1000 | compact | 4.8453 | 3.3291 | 31.3% | 39019 → 22012 |
| distinct_1000 | compact_blank | 6.9101 | 5.2443 | 24.1% | 46019 → 29012 |
| distinct_1000 | combined | 15.3860 | 11.9735 | 22.2% | 76021 → 59012 |
| depth_200 | stringify | 0.2724 | 0.2425 | 11.0% | 2225 → 1613 |
| depth_200 | snake_case | 0.4872 | 0.4898 | -0.5% | 4034 → 3422 |
| depth_200 | symbolize | 0.2783 | 0.2480 | 10.9% | 2225 → 1613 |
| depth_200 | compact | 0.3158 | 0.2917 | 7.6% | 2626 → 2014 |
| depth_200 | compact_blank | 0.4373 | 0.4053 | 7.3% | 3027 → 2415 |
| depth_200 | combined | 0.6496 | 0.5789 | 10.9% | 4437 → 3823 |

The deep `snake_case` case is effectively unchanged: its median is 0.5% higher,
with overlapping sample ranges (baseline 0.480–0.505 ms, candidate 0.475–0.503 ms).
No speed improvement is claimed for that case.

Raw data: [baseline](benchmarks/2.2.1.json), [candidate](benchmarks/3.0.0.json).
The committed JSON uses implementation labels instead of machine-local source
paths.

## Optimization decisions

Independent screening runs compared the corrected implementation with a direct
`Hash#each` build, operation partitioning/scalar fast return, and their combination.
For 10,000 keys in the combined pipeline, the corrected baseline took 24.26 ms
and allocated 120,009 objects; direct construction alone took 24.03 ms/110,007
objects; partitioning alone took 18.21 ms/100,014 objects. The combination took
16.90 ms/90,012 objects. Direct construction's isolated time difference is too
small to claim a speed improvement, but its allocation reduction is clear.
The final results above were then collected separately for the selected code.

The implementation normalizes operation names once per call, partitions key and
collection operations once, skips collection dispatch on scalars, and builds
hashes directly without temporary pair arrays. Cycle detection uses an identity
hash of active ancestors, so shared acyclic collections remain valid. Its retained
bookkeeping grows with nesting depth rather than all visited objects.

No key cache was added: the selected changes already help repeated and distinct
keys, while caching would add state and require extra care around key/leaf
identity. Collections are still copied per occurrence; heavily shared input graphs
can expand. The optimizations do not turn this API into a graph-preserving copy.

## ActiveSupport comparison

The optional comparison uses ActiveSupport 8.1.3.1 and only ordinary Hash roots,
String keys and collision-free data; outputs are checked for equality first.
It compares `stringify` with `deep_transform_keys(&:to_s)` and constructs a DHT
instance per call on that path. The main table reuses a transformer per case.

- small: DHT 0.0038 ms/28 objects; ActiveSupport 0.0019 ms/10 objects.

- wide_10000: DHT 3.5081 ms/20012 objects; ActiveSupport 2.3428 ms/10002 objects.

ActiveSupport remains faster for these key-only comparisons. It is not a reference
implementation for DHT's recursive cleanup, key-type or collision contracts.
Neither ActiveSupport nor benchmark tooling is a runtime dependency of this gem.

## Reproduce

Run on an otherwise quiet machine using the same Ruby and GC/JIT settings:

```sh
ruby script/benchmark.rb > candidate.json
```

To compare the baseline, extract `lib/` from the baseline commit to a separate
directory and set `DHT_LIB` to its absolute `lib` path:

```sh
DHT_LIB=/absolute/path/to/baseline/lib ruby script/benchmark.rb > baseline.json
```

For the optional ActiveSupport comparison, install that gem in a separate
benchmark environment and set `COMPARE_ACTIVE_SUPPORT=1`. Avoid using the project's
Bundler environment for that optional comparison, since ActiveSupport is not in
the development Gemfile. Use the same script and runtime for both implementations.
