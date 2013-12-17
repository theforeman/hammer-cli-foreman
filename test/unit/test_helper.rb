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

def ctx
  {
    :adapter => :silent ,
    :username => 'admin',
    :password => 'admin',
    :interactive => false
  }
end


require File.join(File.dirname(__FILE__), 'test_output_adapter')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/command')
require File.join(File.dirname(__FILE__), 'helpers/resource_disabled')
