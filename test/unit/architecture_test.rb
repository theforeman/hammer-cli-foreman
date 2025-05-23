require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/architecture'

describe HammerCLIForeman::Architecture do

  include CommandTestHelper

  describe "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:architectures, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Architecture::ListCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    describe "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Name"
      it_should_print_column "Id"
    end

  end


  describe "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::InfoCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    describe "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
      end
    end

  end


  describe "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::CreateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "name missing", []
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  describe "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::DeleteCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  describe "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::UpdateCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=arch", "--new-name=arch2"]
      it_should_accept "id", ["--id=1", "--new-name=arch2"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
      # it_should_fail_with "name or id missing", ["--new-name=arch2"] # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end
end
