require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/realm'

describe HammerCLIForeman::Realm do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:realms, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Realm::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Realm::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Created at", "Updated at"]
        it_should_print_columns ["Realm proxy id", "Realm type"]
      end
    end

  end

  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Realm::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, type, proxy", ["--name=realm", "--realm-type=FreeIPA", "--realm-proxy-id=1"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Realm::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=realm"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Realm::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=realm", "--new-name=realm2"]
      it_should_accept "id", ["--id=1", "--new-name=realm2"]
      # it_should_fail_with "no params", []
      # it_should_fail_with "name or id missing", ["--new-name=arch2", "--description=full_realm_name"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end
