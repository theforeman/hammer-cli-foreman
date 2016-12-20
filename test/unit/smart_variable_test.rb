require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/smart_variable'

describe HammerCLIForeman::SmartVariable do

  include CommandTestHelper

  context "ListCommand" do

    before :each do
      ResourceMocks.smart_variables_index
    end

    let(:cmd) { HammerCLIForeman::SmartVariable::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept "hostgroup id", ["--hostgroup-id=1"]
      it_should_accept "host id", ["--host-id=1"]
      it_should_accept "puppet-class-id", ["--puppet-class-id=1"]
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column "Id"
      it_should_print_column "Variable"
      it_should_print_column "Default Value"
      it_should_print_column "Type"
      it_should_print_column "Class Id"
      it_should_print_column "Puppet class"
    end
  end


  context "InfoCommand" do

    before :each do
      ResourceMocks.smart_variables_show
    end

    let(:cmd) { HammerCLIForeman::SmartVariable::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end


  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::SmartVariable::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "variable", ["--id=1","--variable=name"]
      it_should_accept "description", ["--id=1","--description=descr"]
      it_should_accept "default-value", ["--id=1","--default-value=1"]
      it_should_accept "validator-type", ["--id=1","--validator-type=list"]
      it_should_accept "validator-rule ", ["--id=1","--validator-rule=''"]
      it_should_accept "override-value-order", ["--id=1","--override-value-order=fqdn"]
      it_should_accept "variable-type ", ["--id=1","--variable-type=string"]
      it_should_accept "puppet-class-id", ["--id=1","--puppet-class-id=1"]

      # it_should_fail_with "no params", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::SmartVariable::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "variable", ["--variable=name"]
      it_should_accept "description", ["--variable=name","--description=descr"]
      it_should_accept "default-value", ["--variable=name","--default-value=1"]
      it_should_accept "validator-type", ["--variable=name","--validator-type=list"]
      it_should_accept "validator-rule ", ["--variable=name","--validator-rule=''"]
      it_should_accept "override-value-order", ["--variable=name","--override-value-order=fqdn"]
      it_should_accept "variable-type ", ["--variable=name","--variable-type=string"]
      it_should_accept "puppet-class-id", ["--variable=name","--puppet-class-id=1"]
      # it_should_fail_with "name missing", []
      # TODO: temporarily disabled, parameters are checked in the api
    end

  end


  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::SmartVariable::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "AddOverrideValueCommand" do

    let(:cmd) { HammerCLIForeman::SmartVariable::AddOverrideValueCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "match, value and smart-variable-id", ["--match='environment=Dev'","--value=5","--smart-variable-id=1"]
      it_should_accept "smart-variable, match, value", ["--smart-variable=var", "--match='domain=my.lan'", "--value=1"]
      it_should_fail_with "smart-variable, value", ["--smart-variable-id=1","--value=5"]
    end

  end

  context "RemoveOverrideValueCommand" do

    let(:cmd) { HammerCLIForeman::SmartVariable::RemoveOverrideValueCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id and smart-variable-id", ["--id=1","--smart-variable-id=1"]
      it_should_accept "smart-variable, id", ["--smart-variable=var", "--id=1"]
      # it_should_fail_with "id", ["--id=1"]
      # it_should_fail_with "smart-variable", ["--smart-variable-id=1"]
    end

  end

end
