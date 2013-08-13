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

require 'hammer_cli_foreman'

require_relative 'test_output_adapter'
require_relative 'apipie_resource_mock'
require_relative 'helpers/command'
require_relative 'helpers/resource_disabled'
