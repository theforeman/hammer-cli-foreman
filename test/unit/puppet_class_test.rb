require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/puppet_class'

describe HammerCLIForeman::PuppetClass do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:puppetclasses, :index, {})
    end

    let(:cmd) { HammerCLIForeman::PuppetClass::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      # FIXME: the command should accept search parameters in future
      # it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) do
        # data are retuned in specific format
        HammerCLIForeman.collection_to_common_format(cmd.resource.call(:index)).first.keys.count
      end

      it_should_print_n_records
      it_should_print_column "Id"
      it_should_print_column "Name"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::PuppetClass::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Id"
        it_should_print_column "Name"
        it_should_print_column "Smart variables"
      end
    end

  end

  context "SCParamsCommand" do

    before :each do
      ResourceMocks.smart_class_parameters_index
    end

    let(:cmd) { HammerCLIForeman::PuppetClass::SCParamsCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "puppet-class", ["--puppet-class=cls"]
      it_should_accept "puppet-class-id", ["--puppet-class-id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "SmartVariablesCommand" do

    before :each do
      ResourceMocks.smart_variables_index
    end

    let(:cmd) { HammerCLIForeman::PuppetClass::SmartVariablesCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "puppet-class", ["--puppet-class=cls"]
      it_should_accept "puppet-class-id", ["--puppet-class-id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end
