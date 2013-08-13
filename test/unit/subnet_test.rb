require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Subnet do

  extend CommandTestHelper

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.index[0].length }

      it_should_print_n_records
      it_should_print_columns  ["Id", "Name", "Network", "Mask"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::InfoCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      let(:with_params) { ["--id=1"] }
      it_should_print_n_records 1
      it_should_print_columns ["Id", "Name", "Network", "Mask"]
      it_should_print_columns ["Priority"]
      it_should_print_columns ["DNS", "Primary DNS", "Secondary DNS"]
      it_should_print_columns ["Domain ids", "TFTP", "TFTP id", "DHCP", "DHCP id"]
      it_should_print_columns ["vlan id", "Gateway", "From", "To"]
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::CreateCommand.new("") }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--network=192.168.83.0", "--mask=255.255.255.0"]
      it_should_fail_with "name missing",     ["--network=192.168.83.0", "--mask=255.255.255.0"]
      it_should_fail_with "network missing",  ["--name=arch", "--mask=255.255.255.0"]
      it_should_fail_with "mask missing",     ["--name=arch", "--network=192.168.83.0"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::DeleteCommand.new("") }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Subnet::UpdateCommand.new("") }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--new-name=arch2"]
      it_should_accept "id", ["--id=1", "--new-name=arch2"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=arch2"]
    end

  end
end
