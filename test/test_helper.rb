require 'simplecov'
require 'pathname'

SimpleCov.use_merging true
SimpleCov.start do
  command_name 'MiniTest'
  add_filter 'test'
end
SimpleCov.root Pathname.new(File.dirname(__FILE__) + "../../../")


require 'minitest/autorun'
require 'minitest/spec'
require "minitest-spec-context"
require "mocha/setup"

require 'hammer_cli'
require 'hammer_cli_foreman/testing/api_expectations'

FOREMAN_VERSION = Gem::Version.new(ENV['TEST_API_VERSION'] || '1.17')

include HammerCLIForeman::Testing::APIExpectations
HammerCLI.context[:api_connection].create('foreman') do
  api_connection({}, FOREMAN_VERSION)
end

require 'hammer_cli_foreman'
