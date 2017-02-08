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

FOREMAN_VERSION = Gem::Version.new(ENV['TEST_API_VERSION'] || '1.15')

HammerCLI.context[:api_connection].create('foreman') do
  HammerCLI::Apipie::ApiConnection.new({
    :apidoc_cache_dir => 'test/data/' + FOREMAN_VERSION.to_s,
    :apidoc_cache_name => 'foreman_api',
    :dry_run => true
  })
end

require 'hammer_cli_foreman'
