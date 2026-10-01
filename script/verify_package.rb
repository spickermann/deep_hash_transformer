# frozen_string_literal: true

require "fileutils"
require "rbconfig"
require "rubygems/package"
require "tmpdir"

root = File.expand_path("..", __dir__)
Dir.chdir(root) do
  specification = Gem::Specification.load("deep_hash_transformer.gemspec")
  abort "Cannot load gemspec" unless specification
  FileUtils.mkdir_p("pkg")
  package = File.join(root, "pkg", "#{specification.full_name}.gem")
  environment = ENV.keys.grep(/\ABUNDLE_/).to_h { |key| [key, nil] }
    .merge("RUBYOPT" => nil, "RUBYLIB" => nil)
  system(environment, RbConfig.ruby, "-S", "gem", "build", "deep_hash_transformer.gemspec",
    "--output", package, exception: true)

  archive = Gem::Package.new(package)
  expected = ["README.md", "CHANGELOG.md", "MIT-LICENSE", *Dir["lib/**/*.rb"]].sort
  abort "Unexpected package contents" unless archive.contents.sort == expected
  abort "Unexpected runtime dependencies" unless archive.spec.runtime_dependencies.empty?
  abort "Wrong Ruby requirement" unless archive.spec.required_ruby_version.to_s == ">= 3.0.0"
  abort "Wrong push host" unless archive.spec.metadata["allowed_push_host"] == "https://rubygems.org"

  Dir.mktmpdir("deep-hash-transformer-install-") do |directory|
    environment["GEM_HOME"] = directory
    environment["GEM_PATH"] = directory
    system(environment, RbConfig.ruby, "-S", "gem", "install", "--local", "--no-document",
      "--install-dir", directory, package, chdir: directory, exception: true)
    smoke_test = <<~'RUBY'
      require "deep_hash_transformer"
      installed = Gem.loaded_specs.fetch("deep_hash_transformer")
      prefix = File.realpath(ARGV.fetch(0)) + File::SEPARATOR
      loaded = $LOADED_FEATURES.find { |path| path.end_with?("/deep_hash_transformer.rb") }
      abort "Loaded source checkout" unless File.realpath(loaded).start_with?(prefix)
      abort "Wrong installed version" unless installed.version.to_s == ARGV.fetch(1)
      input = {"über_name" => [{"FooBar" => 1}, nil, false]}
      actual = DeepHashTransformer.new(input).tr("camel_case", :symbolize, :compact_blank)
      abort "Wrong transformed value" unless actual == {überName: [{fooBar: 1}]}
      encoded = [" \t".encode("UTF-16LE")]
      abort "Wrong encoded cleanup" unless DeepHashTransformer.new(encoded).compact_blank == []
      key = Class.new(String).new("FooBar")
      abort "Wrong subclass conversion" unless DeepHashTransformer.new({key => 1}).snake_case == {"foo_bar" => 1}
      cycle = []; cycle << cycle
      begin
        DeepHashTransformer.new(cycle).identity
        abort "Cycle was accepted"
      rescue ArgumentError => error
        abort "Wrong cycle error" unless error.message.include?("cyclic")
      end
      puts "Isolated package OK: #{installed.full_name} on Ruby #{RUBY_VERSION}"
    RUBY
    system(environment, RbConfig.ruby, "-e", smoke_test, directory, specification.version.to_s,
      chdir: directory, exception: true)
  end
end
