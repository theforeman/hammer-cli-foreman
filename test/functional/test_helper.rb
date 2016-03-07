require File.join(File.dirname(__FILE__), '../test_helper')

require 'hammer_cli/testing/command_assertions'
require 'hammer_cli_foreman/testing/api_expectations'

include HammerCLI::Testing::CommandAssertions
include HammerCLIForeman::Testing::APIExpectations
