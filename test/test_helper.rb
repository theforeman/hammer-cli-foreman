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
require "mocha/minitest"

require 'hammer_cli'
require 'hammer_cli_foreman/testing/api_expectations'

FOREMAN_VERSION = ENV['TEST_API_VERSION'] || '3.15'
unless Dir.entries('test/data').include? FOREMAN_VERSION
  raise StandardError.new "Version is not correct"
end

include HammerCLIForeman::Testing::APIExpectations
HammerCLI.context[:api_connection].create('foreman') do
  api_connection({}, Gem::Version.new(FOREMAN_VERSION))
end

require 'hammer_cli_foreman'
