require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Environment do

  extend CommandTestHelper

  before :each do
    HammerCLI::Connection.drop_all
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource.resource_class)
    cmd.stubs(:name_to_id).returns(1)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Environment::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_column "Name"
      it_should_print_column "Id"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Environment::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=env"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
        it_should_print_column "Created at"
        it_should_print_column "Updated at"
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Environment::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env"]
      it_should_fail_with "name missing", []
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Environment::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Environment::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env", "--new-name=env2"]
      it_should_accept "id", ["--id=1", "--new-name=env2"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=env2"]
    end

  end

  context "SCParamsCommand" do

    before :each do
      cmd.class.resource ResourceMocks.smart_class_parameter
    end

    let(:cmd) { HammerCLIForeman::Environment::SCParamsCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end

end
