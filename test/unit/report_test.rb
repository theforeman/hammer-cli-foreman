require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Report do

  extend CommandTestHelper

  before :each do
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource.resource_class)
    cmd.stubs(:name_to_id).returns(1)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Report::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_column "Id"
      it_should_print_column "Host"
      it_should_print_column "Last report"
      it_should_print_column "Applied"
      it_should_print_column "Restarted"
      it_should_print_column "Failed"
      it_should_print_column "Restart Failures"
      it_should_print_column "Skipped"
      it_should_print_column "Pending"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Report::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "no arguments"
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Report::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "id missing", []
    end

  end


end
