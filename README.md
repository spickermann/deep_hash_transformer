# DeepHashTransformer

Transform keys and recursively clean nested hashes and arrays without runtime dependencies.
Combine operations to convert API data into Ruby-friendly structures:

```ruby
require "deep_hash_transformer"

input = {
  "nested-array" => [{"a-key" => "a-value", "b-key" => nil}],
  "foo_bar" => "baz"
}

DeepHashTransformer.new(input).tr(:underscore, :symbolize, :compact)
# => {nested_array: [{a_key: "a-value"}], foo_bar: "baz"}
```

[![License MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](MIT-LICENSE)
[![Gem Version](https://badge.fury.io/rb/deep_hash_transformer.svg)](https://rubygems.org/gems/deep_hash_transformer)
[![Build Status](https://github.com/spickermann/deep_hash_transformer/actions/workflows/CI.yml/badge.svg)](https://github.com/spickermann/deep_hash_transformer/actions/workflows/CI.yml)

## Maintenance status

DeepHashTransformer is in maintenance mode. Its feature set is considered complete,
and no new features are planned. Security fixes may be released when needed.
Compatibility with future Ruby versions is not guaranteed.

For general-purpose recursive key transformations, consider ActiveSupport’s
[`deep_transform_keys`](https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_keys),
which supports nested hashes and arrays.

DeepHashTransformer remains useful for applications that need combined key
transformations and recursive cleanup without runtime dependencies. If that
matches your requirements, the existing functionality remains available and
documented.

## Installation

Ruby **3.0 or newer** is required. CI tests the latest patch releases of Ruby 3.0,
3.1, 3.2, 3.3, 3.4 and 4.0. Older series remain supported while the implementation
can support them without version-specific behavior.

Add `gem "deep_hash_transformer", "~> 3.0"` to your Gemfile and run `bundle install`,
or run `gem install deep_hash_transformer`.

## Operations

```ruby
DeepHashTransformer.new({foo_bar: "baz"}).camel_case
# => {"fooBar" => "baz"}

DeepHashTransformer.new({"FooBar" => "baz"}).tr("snake_case", :symbolize)
# => {foo_bar: "baz"}
```

`tr` accepts known operation names as symbols or strings; other arguments raise
`ArgumentError`. Each operation also has a method of the same name.

| Operation | Effect on keys or collections |
|---|---|
| `camel_case` | `"foo_bar"` → `"fooBar"`; `"über_name"` → `"überName"` |
| `pascal_case` | `"foo_bar"` → `"FooBar"` |
| `snake_case` | `"HTTPServer"` → `"http_server"` |
| `dasherize` | Replaces underscores with dashes: `"foo_bar"` → `"foo-bar"` |
| `underscore` | Replaces dashes with underscores: `:"foo-bar"` → `"foo_bar"` |
| `stringify` | Converts symbol keys to strings: `:foo` → `"foo"` |
| `symbolize` | Converts string keys to symbols: `"foo"` → `:foo` |
| `identity` | Leaves keys unchanged |
| `compact` | Removes `nil` hash values and array elements |
| `compact_blank` | Removes blank hash values and array elements, recursively |

Key operations apply to strings (including subclasses) and symbols. Other key
types are unchanged; collections used as keys are not traversed. Case and
separator conversions return strings; `symbolize` returns symbols. `identity`,
`compact`, and `compact_blank` preserve key types. `tr` without arguments copies
the collection structure without converting keys.

Word-boundary detection remains ASCII-based. There is no acronym registry or
locale-specific inflection: `camel_case` converts `"HTTPServer"` to `"hTTPServer"`.
Its initial-letter lowercasing supports Unicode, but that does not make all word
segmentation Unicode-aware. `underscore` only replaces separators; use
`snake_case` when you also want case boundaries converted.

## Combined operations and collisions

`tr` combines operations in **one recursive traversal**, not a series of complete
transformations. At each hash:

1. Key operations run in their supplied order, and values are recursively transformed.
2. The result hash is assembled. If multiple keys become equal, **the last value wins**.
3. Collection operations run in their supplied order on the result.

Arrays transform their elements before collection operations run. Cleanup thus
proceeds from the inside out. The position of a collection operation relative to
a key operation does not change this model:

```ruby
input = {"a" => 1, :a => nil}
DeepHashTransformer.new(input).tr(:compact, :stringify)
# => {}: stringify first causes a collision; compact then removes the winning nil.
DeepHashTransformer.new(input).tr(:stringify, :compact)
# => {}
```

For complete sequential transformations, use separate instances:

```ruby
cleaned = DeepHashTransformer.new(input).compact
DeepHashTransformer.new(cleaned).stringify
# => {"a" => 1}
```

Key-operation order still matters: `tr(:snake_case, :symbolize)` returns symbol
keys, while `tr(:symbolize, :snake_case)` returns string keys.

## Recursive cleanup and root values

`compact` removes only `nil`, retaining `false`, whitespace, and empty collections.
`compact_blank` additionally removes `false`, empty strings/collections, and
strings containing only whitespace. Zero remains. Blankness honors an object's
`blank?` method when present, otherwise checks string whitespace or `empty?`.
User-defined methods and loaded extensions can therefore affect blankness.

```ruby
DeepHashTransformer.new({a: {b: [nil, {c: " "}]}}).compact_blank
# => {}
DeepHashTransformer.new({a: [nil]}).compact
# => {a: []}
DeepHashTransformer.new([nil, {"FooBar" => 1}]).tr(:snake_case, :compact)
# => [{"foo_bar" => 1}]
```

Array roots are supported. Scalar roots are returned unchanged, even `nil`,
`false`, or whitespace: cleanup removes entries from collections, not the root
itself. Empty roots remain `{}` or `[]`.

Whitespace detection includes Unicode whitespace such as nonbreaking space, and
supports valid UTF-16/UTF-32 strings. Zero-width space is not whitespace here.
Invalid byte sequences raise Ruby argument/encoding errors; they are not silently
discarded. This encoding support concerns cleanup, not every key conversion.

## Mutation, references, and supported structures

The transformer does not mutate ordinary input collections or values. Frozen
collections are accepted. Results contain new, mutable hashes and arrays **per
occurrence**; shared input collections are copied independently. Mutable leaf
objects and unchanged non-string keys remain shared. Mutating a returned leaf
can therefore change the input's leaf; this is not a general-purpose deep copy.
The input is read when a transformation runs, not snapshotted at initialization.

Output collections are ordinary `Hash` and `Array` instances. Subclass identity,
hash defaults/default procs, `compare_by_identity`, and frozen state are not
preserved. Ordinary key equality applies even to identity hashes. Transformed
string keys need not retain their subclass.

Cycles through hash values and array elements raise `ArgumentError` with a
`cyclic Hash/Array structure` message. Repeated references without cycles are
allowed. Recursion depth is bounded by Ruby's stack; extremely deep acyclic
inputs can still raise `SystemStackError`. Heavily shared graphs may expand
substantially because collections are copied per occurrence. Custom methods on
user objects are responsible for their own side effects.

## Ruby and ActiveSupport

Ruby's `transform_keys` and `compact` handle one collection level.
[ActiveSupport's `deep_transform_keys`](https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_keys)
already traverses nested hashes **and arrays**. Use it when that API meets your
needs, especially in an application that already loads ActiveSupport.

DeepHashTransformer offers named, combinable operations and recursive cleanup
without runtime dependencies or core-class extensions. It is not a drop-in
replacement for ActiveSupport's key-type, subclass, or inflection behavior, nor
is it guaranteed to be faster. See [benchmark methodology and results](https://github.com/spickermann/deep_hash_transformer/blob/main/docs/performance.md)
in the source repository.

## Migrating from 2.2.1

Version 3.0.0 intentionally changes these results:

- String operation names now execute instead of silently doing nothing.
- `camel_case` lowercases Unicode initial capitals: `"über_name"` now becomes
  `"überName"`, previously `"ÜberName"`.
- String subclasses used as keys now participate in transformations.
- Cyclic collections raise `ArgumentError` instead of exhausting the stack.
- Arbitrary objects are no longer accepted as operation names via `to_s`.

Review generated keys and possible new collisions, especially if they identify
persisted fields or external API parameters. Last-value collision resolution and
the combined traversal model remain unchanged. Ruby 3.0 support is retained.
README and Changelog are now packaged; specs are no longer included in the gem.

## Development and release

Run `bundle install`, then `bundle exec rake` for tests and Standard.
`ruby script/verify_package.rb` builds the gem under `pkg/`, checks its contents,
and installs/tests that exact package in a temporary isolated gem directory.
It does not publish anything. The ignored local `Gemfile.lock` can differ between
Ruby versions; CI resolves compatible development dependencies for each version.

See [release procedure](https://github.com/spickermann/deep_hash_transformer/blob/main/docs/releasing.md) in the source repository for the
separate review and publication steps. `bundle exec rake release` is a publishing
command: it creates and pushes a Git tag, pushes the branch, and uploads the gem.
It does **not** run the test suite first or create a GitHub Release.

## Contributing

Bug reports and pull requests are welcome at
[spickermann/deep_hash_transformer](https://github.com/spickermann/deep_hash_transformer).
[Fork this repository](https://github.com/spickermann/deep_hash_transformer/fork),
create a branch, add tests for your change, and open a pull request.
Please follow the [Code of Conduct](https://github.com/spickermann/deep_hash_transformer/blob/main/CODE_OF_CONDUCT.md).

## License

[MIT](MIT-LICENSE).
