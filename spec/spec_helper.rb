# frozen_string_literal: true

require 'bundler/setup'
require 'deep_hash_transformer'
require 'deep_hash_transformer/blank'
require 'deep_hash_transformer/collection_operation'
require 'deep_hash_transformer/element_operation'
require 'simplecov'

SimpleCov.start do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  add_filter %w[version.rb initializer.rb]
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
