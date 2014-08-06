require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/hostgroup'

describe HammerCLIForeman::Hostgroup do

  include CommandTestHelper

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index).length }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Label", "Operating System"]
      it_should_print_columns ["Environment", "Model"]
    end

  end

  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Label", "Operating System", "Subnet"]
        it_should_print_columns ["Domain", "Environment", "Puppetclasses", "Ancestry"]
        it_should_print_columns ["Parameters"]
      end
    end

  end

  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no params", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, parent_id, environment_id, architecture_id, domain_id, puppet_proxy_id, operatingsystem_id and more",
          ["--name=hostgroup", "--parent-id=1", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1",
            "--operatingsystem-id=1", "--medium-id=1", "--ptable-id=1", "--subnet-id=1", '--puppet-ca-proxy-id=1', '--puppetclass-ids=1,2']
      # it_should_fail_with "name or id missing",
      #    ["--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1"]
      # TODO: temporarily disabled, parameters are checked in the api
    end
  end

  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, parent_id, environment_id, architecture_id, domain_id, puppet_proxy_id, operatingsystem_id and more",
          ["--id=1 --name=hostgroup2", "--parent-id=1", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1",
            "--operatingsystem-id=1", "--medium-id=1", "--ptable-id=1", "--subnet-id=1", '--puppet-ca-proxy-id=1', '--puppetclass-ids=1,2']
      # it_should_fail_with "no params", []
      # it_should_fail_with "id missing", ["--name=host2"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "SetParameterCommand" do

    before :each do
      ResourceMocks.parameters_index
    end

    let(:cmd) { HammerCLIForeman::Hostgroup::SetParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, value and hostgroup id", ["--name=name", "--value=val", "--hostgroup-id=id"]
      it_should_fail_with "name missing", ["--value=val", "--hostgroup-id=1"]
      it_should_fail_with "value missing", ["--name=name", "--hostgroup-id=1"]
      # it_should_fail_with "hostgroup id missing", ["--name=name", "--value=val"] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::DeleteParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name and hostgroup id", ["--name=param", "--hostgroup-id=id"]
      # it_should_fail_with "name missing", ["--hostgroup-id=id"]
      # it_should_fail_with "hostgroup id missing", ["--name=param"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "SCParamsCommand" do

    before :each do
      ResourceMocks.smart_class_parameters_index
    end

    let(:cmd) { HammerCLIForeman::Hostgroup::SCParamsCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

end

