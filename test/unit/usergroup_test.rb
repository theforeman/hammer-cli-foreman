require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/usergroup'

describe HammerCLIForeman::Usergroup do

  include CommandTestHelper


  describe "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:usergroups, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Usergroup::ListCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
      it_should_accept 'organization', ['--organization-id=1']
      it_should_accept 'location', ['--location-id=1']
    end

    describe "output" do
      it_should_print_column "Id"
      it_should_print_column "Name"
      it_should_print_column "Admin"
    end

  end

  describe "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Usergroup::InfoCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=ug"]
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end

    describe "output" do
      with_params ["--id=1"] do
        it_should_print_column "Id"
        it_should_print_column "Name"
        it_should_print_column "Admin"
        it_should_print_column "Users"
        it_should_print_column "User groups"
        it_should_print_column "Roles"
        it_should_print_column "Created at"
        it_should_print_column "Updated at"
      end
    end
  end

  describe "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Usergroup::CreateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=ug"]
      it_should_accept "name, role ids, user group ids and user ids", ["--name=ug", "--role-ids=1,2,3", "--user-group-ids=1,2,3", "--user-ids=1,2,3"]
      it_should_accept 'organization', %w[--name=ug --organization-id=1]
      it_should_accept 'location', %w[--name=ug --location-id=1]
    end
  end

  describe "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Usergroup::DeleteCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=ug"]
      it_should_accept "id", ["--id=1"]
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end
  end

  describe "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Usergroup::UpdateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=ug"]
      it_should_accept "id", ["--id=1"]
      it_should_accept "name and new name", ["--name=ug", "--new-name=ug2"]
      it_should_accept "id, new name, role ids, user group ids and user ids", ["--id=1", "--new-name=ug", "--role-ids=1,2,3", "--user-group-ids=1,2,3", "--user-ids=1,2,3"]
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end
  end
end
