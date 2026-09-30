# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "deep_hash_transformer/version"

Gem::Specification.new do |spec|
  spec.authors = ["Martin Spickermann"]
  spec.email = ["spickermann@gmail.com"]
  spec.homepage = "https://github.com/spickermann/deep_hash_transformer"
  spec.license = "MIT"

  spec.name = "deep_hash_transformer"
  spec.version = DeepHashTransformer::VERSION

  spec.summary = "Transforms keys and cleans deeply nested hashes and arrays"
  spec.description = <<-DESCRIPTION
    Dependency-free key transformations and recursive cleanup for nested hashes and arrays.
  DESCRIPTION

  spec.files = ["CHANGELOG.md", "MIT-LICENSE", "README.md", *Dir["lib/**/*.rb"]]

  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
end
