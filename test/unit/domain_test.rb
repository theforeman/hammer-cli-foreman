require_relative 'test_helper'
require_relative 'apipie_resource_mock'


describe HammerCLIForeman::Domain do

  extend CommandTestHelper

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Domain::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.index[0].length }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Created at", "Updated at"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Domain::InfoCommand.new("") }

    before :each do
      cmd.class.stubs(:get_parameters).returns([])
    end

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      let(:with_params) { ["--id=1"] }
      it_should_print_n_records 1
      it_should_print_columns ["Id", "Name", "Created at", "Updated at"]
      it_should_print_columns ["DNS Id", "Full Name"]
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Domain::CreateCommand.new("") }

    context "parameters" do
      it_should_accept "name, fullname", ["--name=domain", "--fullname=full_domain_name"]
      it_should_fail_with "name missing", ["--full-name=full_domain_name"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Domain::DeleteCommand.new("") }

    context "parameters" do
      it_should_accept "name", ["--name=domain"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Domain::UpdateCommand.new("") }

    context "parameters" do
      it_should_accept "name", ["--name=domain", "--new-name=domain2", "--fullname=full_domain_name"]
      it_should_accept "id", ["--id=1", "--new-name=domain2", "--fullname=full_domain_name"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=arch2", "--fullname=full_domain_name"]
    end

  end


  context "SetCommand" do

    before :each do
      cmd.class.resource.stubs(:index).returns([[],""])
    end

    let(:cmd) { HammerCLIForeman::Domain::SetParameterCommand.new("") }

    context "parameters" do
      it_should_accept "name, value and domain name", ["--name=name", "--value=val", "--domain-name=name"]
      it_should_accept "name, value and domain id", ["--name=name", "--value=val", "--domain-id=id"]
      it_should_fail_with "name missing", ["--value=val", "--domain-name=name"]
      it_should_fail_with "value missing", ["--name=name", "--domain-name=name"]
      it_should_fail_with "domain name or id missing", ["--name=name", "--value=val"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Domain::DeleteParameterCommand.new("") }

    context "parameters" do
      it_should_accept "name and domain name", ["--name=domain", "--domain-name=name"]
      it_should_accept "name and domain id", ["--name=domain", "--domain-id=id"]
      it_should_fail_with "name missing", ["--domain-name=name"]
      it_should_fail_with "domain name or id missing", ["--name=name"]
    end

  end

end
