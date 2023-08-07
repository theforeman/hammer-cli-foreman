require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/role'

describe HammerCLIForeman::Role do

  include CommandTestHelper


  describe "ListCommand" do

    let(:cmd) { HammerCLIForeman::Role::ListCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:roles, :index, [])
    end

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    describe "output" do
      it_should_print_column "Id"
      it_should_print_column "Name"
    end

  end


  describe "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Role::InfoCommand.new("", ctx) }

    describe "output" do

      with_params ["--name=role"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Builtin"]
      end
    end

  end


  describe "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Role::CreateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=role"]
    end

    with_params ["--name=role"] do
      it_should_call_action :create, {'role' => {'name' => 'role'}}
    end
  end

  describe "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Role::DeleteCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=role"]
      it_should_accept "id", ["--id=1"]
    end
  end

  describe "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Role::UpdateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=role"]
      it_should_accept "id", ["--id=1"]
      it_should_accept "name and new name", ["--name=role", "--new-name=role2"]
    end

    with_params ['--id=1', '--new-name=role2'] do
      it_should_call_action :update, { 'id' => '1', 'role' => { 'name' => 'role2' } }
    end

  end

  describe "FiltersCommand" do

    let(:cmd) { HammerCLIForeman::Role::FiltersCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:filters, :index, [])
    end

    describe "parameters" do
      it_should_accept "name", ["--name=role"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "no arguments"
    end

    describe "output" do
      with_params ["--id=1"] do
        it_should_print_column "Id"
        it_should_print_column "Resource type"
        it_should_print_column "Search"
        it_should_print_column "Role"
        it_should_print_column "Permissions"
      end
    end

  end

end
