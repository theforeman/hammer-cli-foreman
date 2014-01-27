require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'test_output_adapter')


describe HammerCLIForeman::ComputeResource do

  extend CommandTestHelper

  before :each do
    HammerCLI::Connection.drop_all
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource.resource_class)
    cmd.stubs(:name_to_id).returns(1)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::ComputeResource::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_columns ["Name", "Id", "Provider"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::ComputeResource::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      it_should_fail_with "no arguments"
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
      it_should_fail_with "name missing", ["--url=http://some.org", "--provider=Libvirt"]
      it_should_fail_with "url missing", ["--name=arch", "--provider=Libvirt"]
      it_should_fail_with "provider missing", ["--name=arch", "--url=http://some.org"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::ComputeResource::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::ComputeResource::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--new-name=arch2"]
      it_should_accept "id", ["--id=1", "--new-name=arch2"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=arch2"]
    end

  end


end
