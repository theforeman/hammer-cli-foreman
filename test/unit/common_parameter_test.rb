require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::CommonParameter do

  extend CommandTestHelper

  let(:resource_mock) { ApipieResourceMock.new(cmd.class.resource.resource_class) }

  before :each do
    cmd.class.resource resource_mock
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::CommonParameter::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_columns  ["Name", "Value"]
    end

  end


  context "SetCommand" do

    let(:cmd) { HammerCLIForeman::CommonParameter::SetCommand.new("", ctx) }
    before :each do
      resource_mock.stub_method(:index, [])
    end

    context "parameters" do
      it_should_accept "name and value", ["--name=param", "--value=val"]
      it_should_fail_with "name missing", ["--value=val"]
      it_should_fail_with "value missing", ["--name=param"]
    end

    context "adding params" do
      with_params ["--name=param", "--value=val"] do
        it_should_call_action :create, {'common_parameter' => {'name' => 'param', 'value' => 'val'}, 'id' => 'param'}
      end
    end

    context "updating params" do
      before :each do
        resource_mock.stub_method(:index, [{'common_parameter' => {'name' => 'param'}}])
      end

      with_params ["--name=param", "--value=val"] do
        it_should_call_action :update, {'common_parameter' => {'name' => 'param', 'value' => 'val'}, 'id' => 'param'}
      end
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::CommonParameter::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      it_should_fail_with "name missing", []
    end

  end

end
