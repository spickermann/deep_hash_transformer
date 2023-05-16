# DeepHashTransformer

The `DeepHashTransformer` helps to translate keys in deeply nested hash (and array) structures.

In opposite to the ActiveSupport's `deep_transform_keys` method `deep_transform_keys` is the `DeepHashTransformer` able to transform keys in hashes that are stored in nested arrays, for example a structure like this `{ foo: [{ bar: 1 }, { bar: 2 }] }`

A good use-case might be the transformation of a JSON API style hash (dasherized string keys) the was returned by an API to a hash that follows common Ruby idioms (symbolized underscore keys), see [Complex Example](#complex-example) below.

[![License MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/spickermann/deep_hash_transformer/blob/main/MIT-LICENSE)
[![Gem Version](https://badge.fury.io/rb/deep_hash_transformer.svg)](https://badge.fury.io/rb/deep_hash_transformer)
[![Build Status](https://github.com/spickermann/deep_hash_transformer/actions/workflows/CI.yml/badge.svg)](https://github.com/spickermann/deep_hash_transformer/actions/workflows/CI.yml)
[![Coverage Status](https://coveralls.io/repos/spickermann/deep_hash_transformer/badge.svg?branch=main)](https://coveralls.io/r/spickermann/deep_hash_transformer?branch=main)
[![Code Climate](https://codeclimate.com/github/spickermann/deep_hash_transformer/badges/gpa.svg)](https://codeclimate.com/github/spickermann/deep_hash_transformer)

## Installation

Include the gem to your Gemfile:

```ruby
gem 'deep_hash_transformer'
```

When you are still on Ruby 2.2 – 2.4:

```ruby
gem 'deep_hash_transformer', '~> 1.0.0'
```

When you are still on Ruby 2.1 or below:

```ruby
gem 'deep_hash_transformer', '~> 0.1.1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deep_hash_transformer

## Usage

The latest version of the `DeepHashTransformer` has the following key transformation operations implemented:

<dl>
  <dt><code>:camel_case</code></dt>
  <dd>translates keys into <code>CamelCase</code>, example: <code>"foo_bar" => "FooBar"</code></dd>
  <dt><code>:dasherize</code></dt>
  <dd>translates underscores in keys into dashes, example: "foo_bar" => "foo-bar"</dd></dd>
  <dt><code>:identity</code></dt>
  <dd>returns the keys unchanged</dd>
  <dt><code>:pascal_case</code></dt>
  <dd>translates keys into <code>pascalCase</code>, example: <code>"foo_bar" => "fooBar"</code></dd>
  <dt><code>:snake_case</code></dt>
  <dd>translates keys into <code>snake_case</code>, example: <code>"FooBar" => "foo_bar"</code></dd>
  <dt><code>:stringify</code></dt>
  <dd>translates symbol keys into strings, example <code>:fooBar => "fooBar"</code></dd>
  <dt><code>:symbolize</code></dt>
  <dd>translates string keys into symbos, example <code>"fooBar" => :fooBar</code></dd>
  <dt><code>:underscore</code></dt>
  <dd>translates dashes in keys into underscores, example: <code>:foo-bar => "foo_bar"</code></dd>
  <dt><code>:compact</code></dt>
  <dd>removed <code>nil</code> values from the hash, example: <code>{ a: 1, b: nil } => { a: 1 }</code></dd>
  <dt><code>:compact_blank</code></dt>
  <dd>removed blank values (<code>nil</code>, <code>false</code>, or empty values from the hash, example: <code>{ a: 1, b: '' } => { a: 1 }</code></dd>
</dl>

All transformations can be called by their names, for example:

```ruby
DeepHashTransformer.new({ foo_bar: 'baz' }).dasherize
#=> { 'foo-bar' => 'baz' }
```

Or you can use `tr` to chain multiple transformations:

```ruby
DeepHashTransformer.new({ 'foo-bar' => 'baz' }).tr(:underscore, :symbolize)
#=> { foo_bar: 'baz' }
```

It is worth noting that the `DeepHashTransformer` only transforms string or symbol keys and leaves all other types untouched:

```ruby
DeepHashTransformer.new({ 1 => 'foo', :bar => 'bar', Object => 'baz' }).stringify
#=> { 1 => 'foo', 'bar' => 'bar', Object => 'baz' }
```

All transformations apart from `symbolize` return per default hashes with stringify keys. When you want to have symbolized keys to be returned then use `tr` to chain your required transformation with `:symbolize`

## Complex Example

`DeepHashTransformer` transforms all hash keys – even if the key is nested in another hash or stored in a nested array. This is its biggest advantage over ActiveSupport's `deep_transform_keys` method which is not able to handle hashes in nested arrays.

Example: Transformation of a JSON API style hash (dasherized string keys) to a hash that follows common Ruby idioms (symbolized underscore keys).

```ruby
json_api_style = {
  'nested-array' => [
    { 'a-key' => 'a-value', 'b-key' => nil }
  ],
  'foo_bar' => 'baz'
}

DeepHashTransformer.new(json_api_style).tr(:underscore, :symbolize, :compact)
#=> {
#     nested_array: [
#       { a_key: 'a-value' }
#     ],
#     foo_bar: 'baz'
#   }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spickermann/deep_hash_transformer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

1. [Fork it](http://github.com/spickermann/has_configuration/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
