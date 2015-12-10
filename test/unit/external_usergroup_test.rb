require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'test_output_adapter')

require 'hammer_cli_foreman/usergroup'

describe HammerCLIForeman::ExternalUsergroup do
  include CommandTestHelper

  context "ListCommand" do
    let(:cmd) { HammerCLIForeman::ExternalUsergroup::ListCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:external_usergroups, :index, [])
    end

    context "parameters" do
      it_should_accept "user group name", ["--user-group=cr"]
      it_should_accept "user group id", ["--user-group-id=1"]
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index, :usergroup_id => 1)) }

      with_params ["--user-group-id=1"] do
        it_should_print_n_records
        it_should_print_column "Id"
        it_should_print_column "Name"
        it_should_print_column "Auth source"
      end
    end
  end

  context "InfoCommand" do
    let(:cmd) { HammerCLIForeman::ExternalUsergroup::InfoCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:external_usergroups, :show, {})
    end

    context "parameters" do
      it_should_accept "user group name and external usergroup's id", ["--user-group=cr", "--id=1"]
      it_should_accept "user group id and external usergroup's id", ["--user-group-id=1", "--id=1"]
    end

    context "output" do
      with_params ["--user-group-id=1", "--id=1"] do
        it_should_print_column "Name"
        it_should_print_column "Auth source"
      end
    end
  end

  context "RefreshExternalUsergroupsCommand" do
    let(:cmd) { HammerCLIForeman::ExternalUsergroup::RefreshExternalUsergroupsCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:external_usergroups, :refresh, [])
    end

    context "parameters" do
      it_should_accept "user group name and external usergroup's id", ["--user-group=cr", "--id=1"]
      it_should_accept "user group id and external usergroup's id", ["--user-group-id=1", "--id=1"]
    end

    context "output" do
      with_params ["--user-group-id=1", "--id=1"] do
        it_should_print_column "Name"
        it_should_print_column "Auth source"
      end
    end
  end

  context "CreateCommand" do
    let(:cmd) { HammerCLIForeman::ExternalUsergroup::CreateCommand.new("", ctx) }

    context "parameters" do
      # it_should_fail_with "no name", ["--auth-source-id=1", "--user-group-id=1"]
      it_should_accept "all required params", ["--name=aabbcc123", "--auth-source-id=1", "--user-group-id=1"]
    end
  end


  context "DeleteCommand" do
    let(:cmd) { HammerCLIForeman::ExternalUsergroup::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id and user group's id", ["--id=1", "--user-group-id=1"]
      it_should_accept "id and user group's name", ["--id=1", "--user-group=ec2"]
    end
  end


  context "UpdateCommand" do
    let(:cmd) { HammerCLIForeman::ExternalUsergroup::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id and user group's id", ["--id=1", "--user-group-id=1"]
      it_should_accept "id and user group's name", ["--id=1", "--user-group=ec2"]
      it_should_accept "all available params", ["--id=1", "--name=img", "--auth-source-id=1", "--user-group-id=1"]
    end
  end
end
