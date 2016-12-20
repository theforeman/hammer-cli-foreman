require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/subnet'

describe HammerCLIForeman::Subnet do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:subnets, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Subnet::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns  ["Id", "Name", "Network", "Mask"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do

      with_params ["--name=subnet"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Network", "Mask"]
        it_should_print_columns ["Priority"]
        it_should_print_columns ["DNS", "Primary DNS", "Secondary DNS"]
        it_should_print_columns ["Domains", "TFTP", "DHCP"]
        it_should_print_columns ["VLAN ID", "Gateway", "From", "To"]
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--network=192.168.83.0", "--mask=255.255.255.0"]
      # it_should_fail_with "name missing",     ["--network=192.168.83.0", "--mask=255.255.255.0"]
      # it_should_fail_with "network missing",  ["--name=arch", "--mask=255.255.255.0"]
      # it_should_fail_with "mask missing",     ["--name=arch", "--network=192.168.83.0"]
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--new-name=arch2"]
      it_should_accept "id", ["--id=1", "--new-name=arch2"]
      # it_should_fail_with "no params", []
      # it_should_fail_with "name or id missing", ["--new-name=arch2"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end
end
