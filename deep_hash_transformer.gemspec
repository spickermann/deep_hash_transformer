lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deep_hash_transformer/version'

Gem::Specification.new do |spec|
  spec.authors       = ['Martin Spickermann']
  spec.email         = ['spickermann@gmail.com']
  spec.homepage      = 'https://github.com/spickermann/deep_hash_transformer'

  spec.name          = 'deep_hash_transformer'
  spec.version       = DeepHashTransformer::VERSION

  spec.summary       = 'Transforms deeply nested hash structure'
  spec.description   = <<-DESCRIPTION
    DeepHashTransformer helps to transform deeply nested hash structures
  DESCRIPTION

  spec.license       = 'MIT'

  spec.files         = Dir['CHANGELOG', 'MIT-LICENSE', 'README', 'lib/**/*', 'spec/**/*']

  spec.require_paths = ['lib']

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('coveralls')
  spec.add_development_dependency('rubocop')
end
