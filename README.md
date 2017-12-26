# DeepHashTransformer

The `DeepHashTransformer` helps to translate keys of deeply nested hash (and array) structures.

[![License MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/spickermann/deep_hash_transformer/blob/master/MIT-LICENSE)
[![Gem Version](https://badge.fury.io/rb/deep_hash_transformer.svg)](https://badge.fury.io/rb/deep_hash_transformer)
[![Build Status](https://travis-ci.org/spickermann/deep_hash_transformer.svg?branch=master)](https://travis-ci.org/spickermann/deep_hash_transformer)
[![Coverage Status](https://coveralls.io/repos/spickermann/deep_hash_transformer/badge.svg?branch=master)](https://coveralls.io/r/spickermann/deep_hash_transformer?branch=master)
[![Code Climate](https://codeclimate.com/github/spickermann/deep_hash_transformer/badges/gpa.svg)](https://codeclimate.com/github/spickermann/deep_hash_transformer)
[![Dependency Status](https://gemnasium.com/badges/github.com/spickermann/deep_hash_transformer.svg)](https://gemnasium.com/github.com/spickermann/deep_hash_transformer)
[![Security](https://hakiri.io/github/spickermann/deep_hash_transformer/master.svg)](https://hakiri.io/github/spickermann/deep_hash_transformer/master)

## Installation

Include the gem to your Gemfile:

```ruby
gem 'deep_hash_transformer'
```

If you are still use Ruby 2.1 or below:

```ruby
gem 'deep_hash_transformer', '~> 0.1.1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deep_hash_transformer

## Usage

The `DeepHashTransformer` has currently the following key transformations implemented:

```ruby
dasherize:  ->(val) { val.to_s.tr('_', '-') }
identity:   ->(val) { val }
stringify:  ->(val) { val.to_s }
symbolize:  ->(val) { val.to_sym }
underscore: ->(val) { val.to_s.tr('-', '_') }
```

Each transformation can be called by its name:

```ruby
DeepHashTransformer.new({ foo_bar: 'baz' }).dasherize
#=> { 'foo-bar' => 'baz' }
```

Or `tr` can be used to chain multiple transformations:

```ruby
DeepHashTransformer.new({ 'foo-bar' => 'baz' }).tr(:underscore, :symbolize)
#=> { foo_bar: 'baz' }
```

It is worth noting that `DeepHashTransformer` transforms only string or symbol keys and leaves other types untouched:

```ruby
DeepHashTransformer.new({ 1 => 'foo', 2 => 'bar' }).symbolize
#=> { 1 => 'foo', 2 => 'bar' }
```

The `dasherize` and the `underscore` transformations return hashes with stringify keys.

## Complex example

`DeepHashTransformer` transforms all hash keys - even if the key is nested in another hash or stored in an nested array. This is it's biggest advantage over ActiveSupport's `deep_transform_keys` method that doesn't care of hashes in nested arrays.

A good complex example might be the transformation of a JSON API style hash (dasherized string keys) to an hash that follows common Ruby idioms (symbolized underscore keys):

```ruby
json_api_style = {
  'nested-array' => [
    { 'a-key' => 'a-value' }
  ],
  'foo_bar' => 'baz'
}

DeepHashTransformer.new(json_api_style).tr(:underscore, :symbolize)
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
5. Create new Pull Request


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

