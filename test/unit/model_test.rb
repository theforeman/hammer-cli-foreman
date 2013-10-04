require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Model do

  extend CommandTestHelper

  before :each do
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource.resource_class)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Model::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_column "Name"
      it_should_print_column "Id"
      it_should_print_column "Vendor class"
      it_should_print_column "HW model"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Model::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=model"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Name"
        it_should_print_column "Id"
        it_should_print_column "Vendor class"
        it_should_print_column "HW model"
        it_should_print_column "Info"
        it_should_print_column "Created at"
        it_should_print_column "Updated at"
      end
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Model::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=model", "--info=description", "--vendor-class=class", "--hardware-model=model"]
      it_should_fail_with "name missing", ["--info=description", "--vendor-class=class", "--hardware-model=model"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Model::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=model"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Model::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=model", "--new-name=model2", "--info=description", "--vendor-class=class", "--hardware-model=model"]
      it_should_accept "id", ["--id=1", "--new-name=model2", "--info=description", "--vendor-class=class", "--hardware-model=model"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=model2", "--info=description", "--vendor-class=class", "--hardware-model=model"]
    end

  end
end
