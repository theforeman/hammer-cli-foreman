require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/environment'

describe HammerCLIForeman::Environment do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:environments, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Environment::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Name"
      it_should_print_column "Id"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Environment::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=env"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
        it_should_print_column "Created at"
        it_should_print_column "Updated at"
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Environment::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env"]
      # it_should_fail_with "name missing", []
      # TODO: temporarily disabled, parameters are checked by the api
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Environment::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Environment::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env", "--new-name=env2"]
      it_should_accept "id", ["--id=1", "--new-name=env2"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
      # it_should_fail_with "name or id missing", ["--new-name=env2"] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "SCParamsCommand" do

    before :each do
      ResourceMocks.smart_class_parameters_index
    end

    let(:cmd) { HammerCLIForeman::Environment::SCParamsCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "environment", ["--environment=env"]
      it_should_accept "environment-id", ["--environment-id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end
