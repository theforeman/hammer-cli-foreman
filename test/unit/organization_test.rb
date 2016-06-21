require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'helpers/resource_disabled')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/organization'

describe HammerCLIForeman::Organization do

  include CommandTestHelper
  extend ResourceDisabled

  context "ListCommand" do

    before :each do
      ResourceMocks.organizations_index
    end

    let(:cmd) { HammerCLIForeman::Organization::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Description"
      it_should_print_column "Name"
      it_should_print_column "Id"
    end

    it_should_fail_when_disabled
  end


  context "InfoCommand" do

    before :each do
      ResourceMocks.organizations_show
    end

    let(:cmd) { HammerCLIForeman::Organization::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
        it_should_print_column "Parent"
        it_should_print_column "Created at"
        it_should_print_column "Updated at"
      end
    end

    with_params ["--id=1"] do
      it_should_fail_when_disabled
    end
  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Organization::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=org"]
      # it_should_fail_with "name missing", []
      # TODO: temporarily disabled, parameters are checked in the api
    end

    with_params ["--name=org"] do
      it_should_fail_when_disabled
    end
  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Organization::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=org"]
      it_should_accept "id", ["--id=1"]

      # it_should_fail_with "name or id missing", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    with_params ["--id=1"] do
      it_should_fail_when_disabled
    end
  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Organization::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=org", "--new-name=org2"]
      it_should_accept "id", ["--id=1", "--new-name=org2"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
      # it_should_fail_with "name or id missing", ["--new-name=org2"] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    with_params ["--id=1"] do
      it_should_fail_when_disabled
    end
  end
end
