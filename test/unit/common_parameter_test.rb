require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/common_parameter'

describe HammerCLIForeman::CommonParameter do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:common_parameters, :index, [])
    end

    let(:cmd) { HammerCLIForeman::CommonParameter::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns  ["Name", "Value", "Type"]
    end

  end


  context "SetCommand" do
    before do
      ResourceMocks.common_parameter_show
    end

    let(:cmd) { HammerCLIForeman::CommonParameter::SetCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, value and hidden-value", ["--name=param", "--value=val", "--hidden-value=true"]
      # it_should_fail_with "name missing", ["--value=val"]
      # it_should_fail_with "value missing", ["--name=param"]
      # TODO: temporarily disabled, parameters are checked by the api
    end

    context "adding params" do
      before :each do
        ResourceMocks.mock_action_calls(
          [:common_parameters, :index, []],
          [:common_parameters, :create,
            {"id" => 1, "name" => "param", "value" => "val", "hidden-value" => false},
            {'common_parameter' => {'name' => 'param', 'value' => 'val', 'parameter_type' => 'string', 'hidden_value' => false}, 'id' => 'param'}])
      end
      with_params ["--name=param", "--value=val", "--hidden-value=false"] do
        it_should_output "Created parameter [param] with value [val].,1,param", :csv
      end
    end

    context "updating params" do
      before :each do
        ResourceMocks.mock_action_calls(
          [:common_parameters, :index, [{'name' => 'param', 'value' => 'test'}]],
          [:common_parameters, :update,
            {"id" => 1, "name" => "param", "value" => "val", "hidden-value" => false},
            {'common_parameter' => {'name' => 'param', 'value' => 'val', 'parameter_type' => 'string', 'hidden_value' => false}, 'id' => 'param'}])
      end

      with_params ["--name=param", "--value=val", "--hidden-value=false"] do
        it_should_output "Parameter [param] updated to [val].,1,param", :csv
      end
    end

    context "adding params with parameter type" do
      before :each do
        ResourceMocks.mock_action_calls(
          [:common_parameters, :index, []],
          [:common_parameters, :create,
            {"id" => 2, "name" => "xyz", "value" => "who", "parameter-type" => "string", "hidden-value" => false},
            {'common_parameter' => {'name' => 'xyz', 'value' => 'who', 'parameter_type' => 'string', 'hidden_value' => false}, 'id' => 'xyz'}])
      end
      with_params ["--name=xyz", "--value=who", "--parameter-type=string", "--hidden-value=false"] do
        it_should_output "Created parameter [xyz] with value [who].,2,xyz", :csv
      end
    end
  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::CommonParameter::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=arch"]
      # it_should_fail_with "name missing", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end
