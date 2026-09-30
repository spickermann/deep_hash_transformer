# frozen_string_literal: true

require "bundler/setup"
require "simplecov"

SimpleCov.start do
  if ENV["CI"]
    require "simplecov_json_formatter"
    require "simplecov-lcov"

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = "coverage/lcov.info"
    end

    formatter SimpleCov::Formatter::MultiFormatter.new [
      SimpleCov::Formatter::JSONFormatter, SimpleCov::Formatter::LcovFormatter
    ]
  end

  track_files "lib/**/*.rb"
  add_filter "/spec/"
  add_filter "/version.rb"
end

require "deep_hash_transformer"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
