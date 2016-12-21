require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/filter'

describe HammerCLIForeman::Filter do

  include CommandTestHelper


  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Filter::ListCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:filters, :index, [])
    end

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      it_should_print_column "Id"
      it_should_print_column "Resource type"
      it_should_print_column "Search"
      it_should_print_column "Role"
      it_should_print_column "Permissions"
    end

  end

  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Filter::InfoCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:filters, :show, {})
    end

    context "parameters" do
      it_should_accept "id", ["--id=1"]
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Id"
        it_should_print_column "Resource type"
        it_should_print_column "Search"
        it_should_print_column "Role"
        it_should_print_column "Permissions"
        it_should_print_column "Created at"
        it_should_print_column "Updated at"
      end
    end
  end

  context "CreateCommand" do
    let(:cmd) { HammerCLIForeman::Filter::CreateCommand.new("", ctx) }

    before do
      # FIXME: remove stubbing option_override once tests are switched to apidoc 1.14+
      cmd.stubs(:option_override).returns(false)
    end

    context "parameters" do
      it_should_accept "role id and permission ids", ["--role-id=1", "--permission-ids=1,2"]
      it_should_accept "role name and permission ids", ["--role=role", "--permission-ids=1,2"]
      it_should_accept "role name, permission ids, search", ["--role=role", "--permission-ids=1,2", "--search='name=*'"]
    end

  end

  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Filter::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
    end
  end

  context "UpdateCommand" do
    let(:cmd) { HammerCLIForeman::Filter::UpdateCommand.new("", ctx) }

    before do
      # FIXME: remove stubbing option_override once tests are switched to apidoc 1.14+
      cmd.stubs(:option_override).returns(false)
    end

    context "parameters" do
      it_should_accept "id, role id and permission ids", ["--id=1", "--role-id=1", "--permission-ids=1,2"]
      it_should_accept "id, role name and permission ids", ["--id=1", "--role=role", "--permission-ids=1,2"]
      it_should_accept "id, role name, permission ids, search", ["--id=1", "--role=role", "--permission-ids=1,2", "--search='name=*'"]
    end

  end


  context "AvailablePermissionsCommand" do

    let(:cmd) { HammerCLIForeman::Filter::AvailablePermissionsCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:permissions, :index, [])
    end

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept "resource type", ["--resource-type=archtitectures"]
      it_should_accept "pagination options", ["--page=2", "--per-page=10"]
    end

    context "output" do
      it_should_print_column "Id"
      it_should_print_column "Name"
      it_should_print_column "Resource"
    end

  end

  context "AvailableResourcesCommand" do

    let(:cmd) { HammerCLIForeman::Filter::AvailableResourcesCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:permissions, :resource_types, [])
    end

    context "parameters" do
      it_should_accept "no arguments"
    end

    context "output" do
      it_should_print_column "Name"
    end

  end
end
