require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Architecture do

  extend CommandTestHelper

  before :each do
    cmd.stubs(:name_to_id).returns(1)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index).length }

      it_should_print_n_records
      it_should_print_column "Name"
      it_should_print_column "Id"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=arch"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_fail_with "name missing", []
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Architecture::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch", "--new-name=arch2"]
      it_should_accept "id", ["--id=1", "--new-name=arch2"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=arch2"]
    end

  end
end
