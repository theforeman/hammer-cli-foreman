require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'test_output_adapter')

require 'hammer_cli_foreman/compute_resource'

describe HammerCLIForeman::ComputeResource do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:compute_resources, :index, [])
    end

    let(:cmd) { HammerCLIForeman::ComputeResource::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns ["Name", "Id", "Provider"]
    end

  end


  context "InfoCommand" do
    before do
      ResourceMocks.compute_resource_show
    end

    let(:cmd) { HammerCLIForeman::ComputeResource::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Name", "Id", "Provider", "Url"]
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::ComputeResource::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, url, provider", ["--name=arch", "--url=http://some.org", "--provider=Libvirt"]
      # it_should_fail_with "name missing", ["--url=http://some.org", "--provider=Libvirt"]
      # it_should_fail_with "url missing", ["--name=arch", "--provider=Libvirt"]
      # it_should_fail_with "provider missing", ["--name=arch", "--url=http://some.org"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::ComputeResource::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::ComputeResource::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--new-name=arch2"]
      it_should_accept "id", ["--id=1", "--new-name=arch2"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
      # it_should_fail_with "name or id missing", ["--new-name=arch2"] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


end
