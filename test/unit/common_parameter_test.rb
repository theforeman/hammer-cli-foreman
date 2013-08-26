require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::CommonParameter do

  extend CommandTestHelper

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::CommonParameter::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.index[0].length }

      it_should_print_n_records
      it_should_print_columns  ["Name", "Value"]
    end

  end


  context "SetCommand" do

    let(:cmd) { HammerCLIForeman::CommonParameter::SetCommand.new("") }
      before :each do
        cmd.stubs(:parameter_exist?).returns(false)
      end

    context "parameters" do
      it_should_accept "name and value", ["--name=param", "--value=val"]
      it_should_fail_with "name missing", ["--value=val"]
      it_should_fail_with "value missing", ["--name=param"]
    end

    with_params ["--name=param", "--value=val"] do
      it_should_call_action :create, {'common_parameter' => {'name' => 'param', 'value' => 'val'}, 'id' => 'param'}
    end

    with_params ["--name=param", "--value=val"] do
      before :each do
        cmd.stubs(:parameter_exist?).returns(true)
      end

      it_should_call_action :update, {'common_parameter' => {'name' => 'param', 'value' => 'val'}, 'id' => 'param'}
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::CommonParameter::DeleteCommand.new("") }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_fail_with "name missing", []
    end

  end

end
