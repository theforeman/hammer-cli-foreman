require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Domain do

  extend CommandTestHelper

  before :each do
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource.resource_class)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Domain::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Domain::InfoCommand.new("", ctx) }

    before :each do
      HammerCLIForeman::Parameter.stubs(:get_parameters).returns([])
    end

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Created at", "Updated at"]
        it_should_print_columns ["DNS Id", "Full Name"]
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Domain::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, fullname", ["--name=domain", "--fullname=full_domain_name"]
      it_should_fail_with "name missing", ["--full-name=full_domain_name"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Domain::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=domain"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Domain::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=domain", "--new-name=domain2", "--fullname=full_domain_name"]
      it_should_accept "id", ["--id=1", "--new-name=domain2", "--fullname=full_domain_name"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=arch2", "--fullname=full_domain_name"]
    end

  end


  context "SetParameterCommand" do

    before :each do
      resource_mock = ApipieResourceMock.new(cmd.class.resource.resource_class)
      resource_mock.stub_method(:index, [])
      cmd.class.resource resource_mock
    end

    let(:cmd) { HammerCLIForeman::Domain::SetParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, value and domain name", ["--name=name", "--value=val", "--domain-name=name"]
      it_should_accept "name, value and domain id", ["--name=name", "--value=val", "--domain-id=id"]
      it_should_fail_with "name missing", ["--value=val", "--domain-name=name"]
      it_should_fail_with "value missing", ["--name=name", "--domain-name=name"]
      it_should_fail_with "domain name or id missing", ["--name=name", "--value=val"]
    end

  end


  context "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::Domain::DeleteParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name and domain name", ["--name=domain", "--domain-name=name"]
      it_should_accept "name and domain id", ["--name=domain", "--domain-id=id"]
      it_should_fail_with "name missing", ["--domain-name=name"]
      it_should_fail_with "domain name or id missing", ["--name=name"]
    end

  end

end
