require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::SmartProxy do

  extend CommandTestHelper

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept "type, page, per_page", ["--type=tftp", "--page=1", "--per-page=2"]
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.index[0].length }

      it_should_print_n_records
      it_should_print_columns  ["Id", "Name", "URL"]
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::InfoCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=proxy"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      let(:with_params) { ["--id=1"] }
      it_should_print_n_records 1
      it_should_print_columns ["Id", "Name", "URL", "Features", "Created at", "Updated at"]
    end

  end


  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::CreateCommand.new("") }

    context "parameters" do
      it_should_accept "name and url", ["--name=proxy", "--url=localhost"]
      it_should_fail_with "name missing",     ["--url=loaclhost"]
      it_should_fail_with "url missing",  ["--name=proxy"]
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::DeleteCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=proxy"]
      it_should_fail_with "name or id missing", []
    end

  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::SmartProxy::UpdateCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1", "--new-name=proxy2", "--url=localhost"]
      it_should_accept "name", ["--name=proxy", "--new-name=proxy2", "--url=localhost"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=proxy2"]
    end

  end
end
