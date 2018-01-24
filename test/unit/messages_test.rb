require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli/testing/messages'

include HammerCLI::Testing::Messages
describe "message formatting" do
  check_all_command_messages(
    HammerCLI::MainCommand,
    HammerCLIForeman::Command,
    except: {
      'HammerCLIForeman::PersonalAccessToken::CreateCommand' => [:success_message]
    }
  )
end
