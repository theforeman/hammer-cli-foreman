require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/domain'

describe HammerCLIForeman::Domain do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:domains, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Domain::ListCommand.new("", ctx) }

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

    let(:cmd) { HammerCLIForeman::Domain::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Created at", "Updated at"]
        it_should_print_columns ["DNS Id", "Description"]
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Domain::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, fullname", ["--name=domain", "--description=full_domain_name"]
      # it_should_fail_with "name missing", ["--full-name=full_domain_name"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Domain::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=domain"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Domain::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=domain", "--new-name=domain2", "--description=full_domain_name"]
      it_should_accept "id", ["--id=1", "--new-name=domain2", "--description=full_domain_name"]
      # it_should_fail_with "no params", []
      # it_should_fail_with "name or id missing", ["--new-name=arch2", "--description=full_domain_name"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "SetParameterCommand" do

    before :each do
      ResourceMocks.parameters_index
    end

    let(:cmd) { HammerCLIForeman::Domain::SetParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, value and domain name", ["--name=name", "--value=val", "--domain=name"]
      it_should_accept "name, value and domain id", ["--name=name", "--value=val", "--domain-id=1"]
      # it_should_fail_with "name missing", ["--value=val", "--domain=name"]
      # it_should_fail_with "value missing", ["--name=name", "--domain=name"]
      # it_should_fail_with "domain name or id missing", ["--name=name", "--value=val"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::Domain::DeleteParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name and domain name", ["--name=param", "--domain=name"]
      it_should_accept "name and domain id", ["--name=param", "--domain-id=1"]

      # it_should_fail_with "name missing", ["--domain=name"]
      # it_should_fail_with "domain name or id missing", ["--name=param"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end
